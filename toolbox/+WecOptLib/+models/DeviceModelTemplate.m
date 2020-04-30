
% Copyright 2020 National Technology & Engineering Solutions of Sandia, 
% LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
% U.S. Government retains certain rights in this software.
%
% This file is part of WecOptTool.
% 
%     WecOptTool is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     WecOptTool is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with WecOptTool.  If not, see <https://www.gnu.org/licenses/>.

classdef (Abstract) DeviceModelTemplate
    
    methods (Abstract)
        
        hydro = getHydrodynamics(obj, mode, params, varargin)
        motion = getMotion(obj, S, hydro, controlType, maxVals)
        powSS = complexConjugate(obj, motion);
        powSS = damping(obj, motion);
        powSS = pseudoSpectral(obj, motion);
    
    end
        
    methods
                
        function [pow, etc] = getPower(obj,             ...
                                       studyDir,        ...
                                       SS,              ...
                                       controlType,     ...
                                       geomMode,        ...
                                       geomParams,      ...
                                       varargin)
        % pow, etc = DeviceModelTemplate.getPower(SS, controlType, ...)
        %
        % Takes a specta S struct or a series of sea-states in a struct 
        % array. getPower will iterate over sea-states and calcualte power.
        %
        % Inputs
        %     studyDir     Path to folder for file storage
        %     SS           Struct or struct array of spectra(S) w/ fields:
        %         SS.S         spectral energy distribution [m^2 s/rad]
        %         SS.w         frequency [rad/s]
        %         SS.ph        phasing
        %         SS.mu        weighting factor
        %     controlType     choose control type for PTO:
        %                     CC: complex conjugate (no constraints)
        %                     PS: pseudo-spectral (with constraints)
        %                      P: proportional damping
        %     geomMode     choose mode for geometry definition;
        %                       geometry inputs are passed in as 
        %                       string-value pairs, see RM3_getNemoh
        %                       documentation for more info.
        %                           scalar: single scaling factor lambda
        %                           parametric: [r1, r2, d1, d2] parameters
        %                           existing: pass existing NEMOH rundir
        %     geomParams      contains parameters for the geometric mode
        %     geomOptions     options to be passed to getHydrodynamics
        %     controlParams   if using the 'PS' control type, optional
        %                       arguments for deltaZmax and deltaFmax
        %                           Note: to use the optional arguments,
        %                           both must be provided
        %
        % Outputs
        %     pow             power weighted by weighting factors
        %     etc             structure with two items, containing pow 
        %                       and the hydro struct from Nemoh
        
        defaultGeomOptions = {};
        defaultControlParams = [];
        
        p = inputParser;
        addOptional(p, 'geomOptions', defaultGeomOptions);
        addOptional(p, 'controlParams', defaultControlParams);
        parse(p, varargin{:});
        
        geomOptions = p.Results.geomOptions;
        controlParams = p.Results.controlParams;

        % Create a folder for this call
        uniqueFolder = obj.getUniqueFolderPath(studyDir);
        
        % Fix geomOptions if in parametric mode
        if strcmp(geomMode, 'parametric')
            geomOptions = [geomOptions, {'nemohDir', uniqueFolder}];
        end
        
        % WEC-Sim hydro structure for RM3
        hydro = obj.getHydrodynamics(geomMode,      ...
                                     geomParams,    ...
                                     geomOptions{:});

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

        % Get the number of sea-states passed
        NSS = length(SS);
                                       
        % Initialize arrays to hold mu, powSS, powPerFreq, freqs
        mus = zeros(NSS, 1);
        powSSs = zeros(NSS, 1);
        powPerFreqs = cell(NSS);
        freqs = cell(NSS);
        n_mu = 0;
        
        % Check sea-state weights
        for iSS = 1:NSS
            
            S = SS(iSS);
            
            if isfield(S, 'mu')
                n_mu = n_mu + 1;    
            end
            
        end
        
        if NSS == 1
            
            % Single sea-state requires no weighting
            SS(1).mu = 1;  
            
        elseif n_mu == 0
            
            % Equalise weightings for multi-sea-states if not given
            for iSS = 1:NSS
                SS(iSS).mu = 1;     
            end            
            
            warn = ['Provided wave spectra have no weightings ' ...
                    '(field mu). Equal weighting presumed.'];
            warning('WaveSpectra:NoWeighting', warn);
            
        elseif n_mu ~= NSS
            
            % Don't allow partial weightings
            msg = ['Weighting field mu must be set for all spectra '    ...
                   'or for none of them.'];
            error(msg)
            
        end

        % Iterate over Sea-States
        for iSS = 1:NSS % TODO - consider parfor?
            % Get Sea-State
            S = SS(iSS);
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
            SS(iSS).powSS = powSS;
            % Save weights/ power to arrays
            mus(iSS) = S.mu;
            powSSs(iSS) = powSS;
            powPerFreqs{iSS} = powPerFreq;
            freqs{iSS} = freq;
        
        end

        % Calculate power across sea-states 
        pow = dot(powSSs(:), mus(:)) / sum([mus]);
        
        etc.geomParams = geomParams;
        etc.mus  = mus;
        etc.pow = powSSs;
        etc.powPerFreq = powPerFreqs;
        etc.freq = freqs;
        etc.hydro = hydro;
        
        % Store the etc struct for this run
        if exist(uniqueFolder,'dir') ~= 7
            mkdir(uniqueFolder)
        end
        
        etcPath = fullfile(uniqueFolder, "etc.mat");
        save(etcPath, '-struct', 'etc');

        end
        
    end
    
    methods (Access=protected)
        
        function folder = getUniqueFolderPath(obj, path)
            
            getCandidateName = @() dec2hex(randi(16777216, 1), 6);
    
            d = dir(path);
            dfolders = d([d(:).isdir] == 1);
            dfolders = dfolders(~ismember({dfolders(:).name},   ...
                                          {'.', '..'}));

            while true
                
                candidateName = getCandidateName();
                
                if ismember(candidateName, {dfolders.name})
                    continue
                end
                
                folder = fullfile(path, candidateName);
                return
                
            end
            
        end
        
    end
    
end
