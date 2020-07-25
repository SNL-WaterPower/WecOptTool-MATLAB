classdef Device < WecOptTool.base.AutoFolder
    % Class representing a device with a given geometry, model and 
    % contoller configuration. Device objects should only be created using 
    % the ``makeDevice`` method of :mat:class:`+WecOptTool.Blueprint` 
    % objects.
    %
    % Attributes:
    %     folder (string): path to data storage folder
    %     geomType (string):
    %         The geometry type associated to this device.
    %     geomParams (cell array):
    %         The geometry definition parameters for this device.
    %     controlType (string):
    %         The controller type associated to this device.
    %     controlParams (cell array):
    %         The controller definition parameters for this device.
    %     modelParams (optional cell array):
    %         The model definition parameters for this device. Defaults to
    %         empty cell array.
    %     hydro (:mat:class:`+WecOptTool.+types.Hydro`):
    %         The Hydro object assosiated to this device geometry
    %     seaState (:mat:class:`+WecOptTool.+types.SeaState`):
    %         The SeaState object passed to the last call of `simulate`.
    %         Empty by default.
    %     motions (array of :mat:class:`+WecOptTool.+types.Motion`):
    %         The Motion objects generated by the last call of `simulate`,
    %         per sea state. Empty by default.
    %     performances (array of :mat:class:`+WecOptTool.+types.Performance`)
    %         The Performance objects generated by the last call of 
    %         `simulate`, per sea state. Empty by default.
    %     aggregation (optional)
    %         If the Blueprint.aggregationHook property is defined, the
    %         result of that function is added here.
    %
    % --
    %
    % Device Properties:
    %     folder - path to data storage folder
    %     geomType - The geometry type associated to this device.
    %     geomParams - The geometry definition parameters for this device.
    %     controlType - The controller type associated to this device.
    %     controlParams - The controller definition parameters for this 
    %                     device.
    %     modelParams - The model definition parameters for this device. 
    %                   Defaults to empty cell array.
    %     hydro - The Hydro object assosiated to this device geometry
    %     seaState - The SeaState object passed to the last call of 
    %                simulate. Empty by default.
    %     motions - The Motion objects generated by the last call of 
    %               simulate, per sea state. Empty by default.
    %     performances - The Performance objects generated by the last 
    %                    call of simulate, per sea state. Empty by default.
    %     aggregation - If the Blueprint.aggregationHook property is 
    %                   defined, the result of that function is added here.
    %
    % Device Methods:
    %     simulate - Determine the performace of the WEC device
    %     saveFolder - Save the data folder and contents
    %
    % See also WecOptTool.Device, WecOptTool.types
    %
    % --
    
    % Copyright 2020 National Technology & Engineering Solutions of Sandia, 
    % LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
    % U.S. Government retains certain rights in this software.
    %
    % This file is part of WecOptTool.
    % 
    %     WecOptTool is free software: you can redistribute it and/or 
    %     modify it under the terms of the GNU General Public License as 
    %     published by the Free Software Foundation, either version 3 of 
    %     the License, or (at your option) any later version.
    % 
    %     WecOptTool is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %     GNU General Public License for more details.
    % 
    %     You should have received a copy of the GNU General Public 
    %     License along with WecOptTool.  If not, see 
    %     <https://www.gnu.org/licenses/>. 
    
    properties
        geomType
        geomParams
        controlType
        controlParams
        modelParams = {}
        hydro
        seaState
        motions
        performances
        aggregation
    end
    
    properties (Access = private)
        staticMotion
        dynamicModelCB
        controllerCB
        aggregationCB
    end
    
    methods (Access = {?WecOptTool.Blueprint ?matlab.unittest.TestCase})
        
        function obj = Device(baseFolder,           ...
                              hydro,                ...
                              staticModelCallback,  ...
                              dynamicModelCallback, ...
                              controllerCallbBack,  ...
                              aggregationCB,        ...
                              geomType,             ...
                              geomParams,           ...
                              controlType,          ...
                              controlParams,        ...
                              modelParams)
            
            if nargin < 1
                baseFolder = [];
            end
                          
            obj = obj@WecOptTool.base.AutoFolder(baseFolder);
            
            if nargin < 1
                return
            elseif nargin == 11
                obj.modelParams = modelParams;
            end
            
            obj.hydro = hydro;
            obj.staticMotion = staticModelCallback(hydro,   ...
                                                   obj.modelParams{:});
            obj.dynamicModelCB = dynamicModelCallback;
            obj.controllerCB = controllerCallbBack;
            obj.aggregationCB = aggregationCB;
            obj.geomType = geomType;
            obj.geomParams = geomParams;
            obj.controlType = controlType;
            obj.controlParams = controlParams;

            
        end
        
    end
    
    methods
        
        function out = simulate(obj, seaState)
            % Determine the performace of the WEC device
            %
            % Arguments:
            %     seaState (:mat:class:`+WecOptTool.+types.SeaState`):
            %         The sea-state(s) to be simulated
            %
            
            if ~isa(seaState, "WecOptTool.types.SeaState")
                errStr = "simulate only accepts SeaState objects";
                error("WecOptTool:Device:NotSeaState", errStr)
            end
            
            obj.seaState = seaState;
            NSS = length(seaState);
            
            mymotions(1:NSS) =  WecOptTool.types.Motion();
            %myperformances(1:NSS) = WecOptTool.types.Performance();
            
            for iSS = 1:NSS
                
                S = seaState(iSS);
                
                smotion = obj.dynamicModelCB(obj.staticMotion, ...
                                             obj.hydro,        ...
                                             S,                ...
                                             obj.modelParams{:});

                if ~isa(smotion, "WecOptTool.types.Motion")
                    errStr = "The dynamic model must return a " +   ...
                             "Motion object";
                    error("WecOptTool:Device:NotMotion", errStr)
                end

                sperformance = obj.controllerCB(smotion,    ...
                                                obj.controlParams{:});
                
%                 if ~isa(sperformance, "WecOptTool.types.Performance")
%                     
%                     errStr = "Controllers must return a " +   ...
%                              "Performance object";
%                     error("WecOptTool:Device:NotPerformance", errStr)
%                     
%                 end
                
                mymotions(iSS) = smotion;
                myperformances(iSS) = sperformance;
                
            end
            
            obj.motions = mymotions;
            obj.performances = myperformances;
            
            % Run the aggregation hook if given
            if ~isempty(obj.aggregationCB)
                obj.aggregation = obj.aggregationCB(seaState,       ...
                                                    obj.hydro,      ...
                                                    obj.motions,    ...
                                                    obj.performances);
            end
            
            % Store the device for this run
            etcPath = fullfile(obj.folder, "device.mat");
            save(etcPath, 'obj');
            
            if nargout
                out = myperformances;
            end
           
        end
    
    end

end
