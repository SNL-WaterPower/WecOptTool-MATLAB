classdef (Abstract) DeviceModelTemplate
    
    methods (Abstract)
        
        [hydro, rundir] = getHydrodynamics(obj, geomMode, geomParams)
        motion = getMotion(obj, S, hydro, controlType, maxVals)
        powSS = complexConjugate(obj, motion);
        powSS = damping(obj, motion);
        powSS = pseudoSpectral(obj, motion);
    
    end
        
    methods
                
        function [pow, etc] = getPower(obj,             ...
                                       SS,              ...
                                       controlType,     ...
                                       geomMode,        ...
                                       geomParams,      ...
                                       controlParams)
        % pow, etc = DeviceModelTemplate.getPower(SS, controlType, ...)
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
        %       geomMode        choose mode for geometry definition;
        %                       geometry inputs are passed in as 
        %                       string-value pairs, see RM3_getNemoh
        %                       documentation for more info.
        %                           scalar: single scaling factor lambda
        %                           parametric: [r1, r2, d1, d2] parameters
        %                           existing: pass existing NEMOH rundir
        %       geomParams      contains parameters for the geometric mode
        %       controlParams   if using the 'PS' control type, optional
        %                       arguments for deltaZmax and deltaFmax
        %                           Note: to use the optional arguments,
        %                           both must be provided
        % Outputs
        %       pow             power weighted by weighting factors
        %       etc             structure with two items, containing pow 
        %                       and the hydro struct from Nemoh

        % WEC-Sim hydro structure for RM3
        [hydro,rundir] = obj.getHydrodynamics(geomMode, geomParams);

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
            % Reassaign SS to be SS of signle sea-state (Is there a better 
            % way?)
            SS = singleSea;
        end

        % Get the name of all passes SS
        seaStateNames = fieldnames(SS);
        % Number of Sea-states
        NSS = length(seaStateNames);
        % Initial arrays to hold mu, powSS, powPerFreq, freqs
        mus = zeros(NSS, 1);
        powSSs = zeros(NSS, 1);
        powPerFreqs = cell(NSS);
        freqs = cell(NSS);

        % Iterate over Sea-States
        for iSS = 1:NSS % TODO - consider parfor?
            % Get Sea-State
            S = SS.(seaStateNames{iSS});
            % TODO: IMPORTANT! Ensure spectra is of WAFO format (e.g. size 
            % Nx1)!
            % Check sea-state weight
            % TODO: Should check if weights across sea states equal 1?
            if ~isfield(S,'mu')
                warn = ['No weighting field mu in wave spectra '    ...
                        'structure S, setting to 1'];
                warning('WaveSpectra:NoWeighting', warn);
                S.mu = 1;          
            end        

            % Calculate spectra power
            motion = obj.getMotion(S,           ...
                                   hydro,       ...
                                   controlType, ...
                                   maxVals);
            
            % TODO: These may need to be templated also
            switch controlType
                case 'CC'
                    [powPerFreq, freq] = obj.complexConjugate(motion);

                case 'P'
                    [powPerFreq, freq] = obj.damping(motion);

                case 'PS'
                    [powPerFreq, freq] = obj.pseudoSpectral(motion);
            end                                  
            
            % Save Power to S (would need to return SS, to be useful)
            powSS = sum(powPerFreq);
            SS.(seaStateNames{iSS}).powSS = powSS;
            % Save weights/ power to arrays
            mus(iSS) = S.mu;
            powSSs(iSS) = powSS;
            powPerFreqs{iSS} = powPerFreq;
            freqs{iSS} = freq;
        
        end

        % Calculate power across sea-states 
        pow = dot(powSSs(:), mus(:)) / sum([mus]);

        etc.mus  = mus;
        etc.pow = powSSs;
        etc.powPerFreq = powPerFreqs;
        etc.freq = freqs;
        etc.hydro = hydro;
        etc.rundir = rundir;

        end
        
    end
    
end


