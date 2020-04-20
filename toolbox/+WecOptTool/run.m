
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

    %% Create the objective function
%     RM3Device = WecOptLib.models.RM3.DeviceModel();
    
%     function pow = obj(x)
% 
%         pow = -1 * RM3Device.getPower(study.spectra,          ...
%                                       study.controlType,      ...
%                                       study.geomMode,         ...
%                                       x,                      ...
%                                       study.controlParams);
%     end
    
    switch study.geomMode
        case 'existing'
            study.out.sol = study.geomX0;
            study.out.fval = study.objFun(study.geomX0);
        otherwise
            % define these parameters as null to allow passing non-default 
            % options
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
            
            %% Call the optimization solver
            tic
            [sol,fval,exitflag,output] = fmincon(@study.objFun,...
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
    end
    
    %     if strcmp(study.geomMode, 'existing')
    %         study.out.sol = study.geomX0;
    %         study.out.fval = study.objFun(study.geomX0);
%         return
%     end
%     
%     %define these parameters as null to allow passing non-default options
%     A = [];
%     b = [];
%     Aeq = [];
%     beq = [];
%     
%     %% Set the optimization options
%     if nargin == 2
%         options = optimOptions;
%     else
%         options = optimoptions('fmincon');
%     end
%     
%     %% Call the optimization
%     tic
%     [sol,fval,exitflag,output] = fmincon(@obj,                  ...
%                                          study.geomX0,          ...
%                                          A,                     ...
%                                          b,                     ...
%                                          Aeq,                   ...
%                                          beq,                   ...
%                                          study.geomLowerBound,  ...
%                                          study.geomUpperBound,  ...
%                                          [],                    ...
%                                          options);
%     toc
%     
%     study.out = struct;
%     study.out.sol = sol;
%     study.out.fval = fval;
%     study.out.exitflag = exitflag;
%     study.out.output = output;
    
end
