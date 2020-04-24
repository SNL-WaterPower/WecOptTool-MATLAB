
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

function run(study, optimOptions)
    % Run a simulation with optional optimiser options
    % 
    % Args:
    %     study (:mat:class:`+WecOptTool.RM3Study`):
    %         configured RM3Study object
    %     optimOptions (optional):
    %         options to fmincon, created with ``optimoptions``
    
    disp("Running study...")
    disp("")

    %% Clean the study directory
    if exist(study.studyDir, 'dir')
        WecOptLib.utils.rmdirRetry(study.studyDir);
    end
    
    %% Add SS to geomOptions for parametric mode
    if strcmp(study.geomMode, 'parametric')
        geomOptions = [study.geomOptions, {'spectra', study.spectra}];
    else
        geomOptions = study.geomOptions;
    end

    %% Create the objective function
    RM3Device = WecOptLib.models.RM3.DeviceModel();
    
    function pow = obj(x)
        warning('off', 'WaveSpectra:NoWeighting')
        pow = -1 * RM3Device.getPower(study.studyDir,           ...
                                      study.spectra,            ...
                                      study.controlType,        ...
                                      study.geomMode,           ...
                                      x,                        ...
                                      geomOptions,            ...
                                      study.controlParams);
    end
    
    if strcmp(study.geomMode, 'existing')
        study.out.sol = study.geomX0;
        study.out.fval = obj(study.geomX0);
        return
    end
    
    %define these parameters as null to allow passing non-default options
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    
    %% Set the optimization options
    if nargin == 2
        options = optimOptions;
    else
        options = optimoptions('fmincon');
    end
    
    %% Call the optimization
    tic
    [sol,fval,exitflag,output] = fmincon(@obj,                  ...
                                         study.geomX0,          ...
                                         A,                     ...
                                         b,                     ...
                                         Aeq,                   ...
                                         beq,                   ...
                                         study.geomLowerBound,  ...
                                         study.geomUpperBound,  ...
                                         [],                    ...
                                         options);
    toc
    
    study.out = struct;
    study.out.sol = sol;
    study.out.fval = fval;
    study.out.exitflag = exitflag;
    study.out.output = output;
    
    % Pick up the etc struct for the optimal solution 
    d = dir(study.studyDir);
    dfolders = d([d(:).isdir] == 1);
    dfolders = dfolders(~ismember({dfolders(:).name}, {'.', '..'}));
    
    foundMatch = false;
    
    for name = {dfolders.name}
        
        rundir = fullfile(study.studyDir, name{1});
        etc = load(fullfile(rundir, 'etc.mat'));
        
        if isequal(study.out.sol, etc.geomParams)
            foundMatch = true;
            break
        end
        
    end
    
    if ~foundMatch
        error('WecOptTool:run:noMatchingOutput',  ...
              "Matching hydrodynamics run not found.")
    end
    
    study.out.rundir = rundir;
    study.out.etc = etc;
    
end
