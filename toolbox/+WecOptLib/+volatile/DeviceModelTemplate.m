classdef (Abstract) DeviceModelTemplate
    
    methods (Abstract)
        
        [hydro, rundir] = getNemoh(obj, geomMode, geomParams)
        forces = getForces(obj, S, hydro, controlType, maxVals)
    
    end
        
    methods
                
        function [pow, etc] = getPower(obj,             ...
                                       SS,              ...
                                       controlType,     ...
                                       geomMode,        ...
                                       geomParams,      ...
                                       controlParams)
        % pow, etc = DeviceModelTemplate.getPower(SS, controlType, geomMode, ...)
        %
        % Takes a specta S or a series of sea-states in a struct.
        % Iterates over sea-states and calcualtes power.
        %
        % Inputs
        %      SS               Struct of Spectra (S)
        %       S               wave spectra structure, with fields:
        %           S.S         spectral energy distribution [m^2 s/rad]
        %           S.w         frequency [rad/s]
        %           S.ph        phasing
        %           S.mu        weighting factor
        %       controlType     choose control type for PTO:
        %                           CC: complex conjugate (no constraints)
        %                           PS: pseudo-spectral (with constraints)
        %                           P: proportional damping
        %       geomMode        choose mode for geometry definition; geometry
        %                       inputs are passed in as string-value pairs, see
        %                       RM3_getNemoh documentation for more info.
        %                           scalar: single scaling factor lambda
        %                           parametric: [r1, r2, d1, d2] parameters
        %                           existing: pass existing NEMOH rundir
        %       geomParams      contains parameters for the geometric mode
        %       controlParams   if using the 'PS' control type, optional arguments for
        %                       deltaZmax and deltaFmax
        %                           Note: to use the optional arguments, both must
        %                           be provided
        % Outputs
        %       pow             power weighted by weighting factors
        %       etc             structure with two items, containing pow and the
        %                       hydro struct from Nemoh
        %
        % Examples:
        % 1) Using scalar input with CC control and scaling factor 1:
        %
        % S = bretschneider([],[8,10],0);
        % [pow, etc] = SeaStatePower(S, 'CC', 'scalar', 1);
        %
        %
        % 2) Using 'PS' control with optional deltaZmax and deltaFmax specified
        %
        % S = bretschneider([],[8,10],0);
        %
        % r1 = 10;       % radius of float
        % r2 = 15;       % radius of sink
        % d1 = 2;        % float depth
        % d2 = 42;       % sink depth
        %
        % deltaZmax = 15;
        % deltaFmax = 1e7;
        %
        % [pow, etc] = RM3_SeaStatePower(S, 'PS', 'parametric', [r1,r2,d1,d2], deltaZmax, deltaFmax);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % WEC-Sim hydro structure for RM3
        [hydro,rundir] = obj.getNemoh(geomMode, geomParams);

        % If PS control must set max Z and F values
        if strcmp(controlType, 'PS') 
            if length(controlParams) == 2
                maxVals = controlParams;
            else
                msg = ['ControlParams must be specified and of form '...
                       '[delta_Zmax,delta_Fmax]'];
                error(msg)
            end
        else
            maxVals = [];
        end

        % If Spectra (S) passed put S into sea state struct (SS) length 1 
        if isfield(SS,'w') && isfield(SS,'S')
            % if no weight for single sea state set weight to 1
            if ~isfield(SS,'mu')
                SS.mu = 1;          
            end  
            % Create empty SS
            singleSea = struct();
            % Store the single sea-state in the temp struct
            singleSea.S1 = SS;
            % Reassaign SS to be SS of signle sea-state (Is there a better way?)
            SS = singleSea;
        end

        % Get the name of all passes SS
        seaStateNames = fieldnames(SS);
        % Number of Sea-states
        NSS = length(seaStateNames);
        % Initial arrays to hold mu, powSS
        mus=zeros(NSS,1);
        powSSs=zeros(NSS,1);

        % Iterate over Sea-States
        for iSS = 1:NSS % TODO - consider parfor?
            % Get Sea-State
            S = SS.(seaStateNames{iSS});
            % TODO: IMPORTANT! Ensure spectra is of WAFO format (e.g. size Nx1)!
            % Check sea-state weight
            % TODO: Should check if weights across sea states equal 1?
            if ~isfield(S,'mu')
                warn = ['No weighting field mu in wave spectra structure S, '...
                        'setting to 1'];
                warning(warn);
                S.mu = 1;          
            end        

            % Calculate spectra power
            forces = obj.getForces(S, hydro, controlType, maxVals);
            
            % TODO: These may need to be templated also
            switch controlType
                case 'CC'
                    powSS = WecOptLib.volatile.complexConjugate(forces);

                case 'P'
                    powSS = WecOptLib.volatile.damping(forces);

                case 'PS'
                    powSS = WecOptLib.volatile.ps(forces);
            end                                  
                                             
                                             
            % Save Power to S (would need to return SS, to be useful)
            SS.(seaStateNames{iSS}).powSS = powSS;
            % Save weights/ power to arrays
            mus(iSS) = S.mu;
            powSSs(iSS)   = powSS;
        
        end

        % Calculate power across sea-states 
        pow = dot(powSSs(:), mus(:)) / sum([mus]);

        etc.mus  = mus;
        etc.pow = powSSs;
        etc.hydro = hydro;
        etc.rundir = rundir;

        end
        
    end
    
end


