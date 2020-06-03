classdef (Abstract) Blueprint < WecOptLib.experimental.base.AutoFolder
    % Abstract class for creating a new WEC blueprint where multiple  
    % geometries and controllers can be added to the blueprint alongside 
    % the model used to describe the WECs motion.
    %
    % A concrete implementation of the Blueprint class is defined as
    % follows::
    %
    %     classdef MyWEC < WecOptLib.experimental.base.Blueprint
    %
    % The abstract properties ``geometryCallbacks``, 
    % ``staticModelCallback``, ``dynamicModelCallback`` and 
    % ``controllerCallbacks`` must be defined, as described below.
    %
    % Attributes:
    %     geometryCallbacks (struct of function handles):
    %         (ABSTRACT) A struct of function handles where each function 
    %         should take a folder path as the first input argument, an 
    %         arbitrary number of additional inputs and return a Hydro 
    %         object. For instance, to include the following function::
    %
    %             function hydro = myGeom(folder, sizeA, sizeB)
    %                 import WecOptLib.experimental.types.Hydro
    %                 ...
    %                 hydro = Hydro(vars)
    %             end
    %
    %         and use one pre-defined callback for an existing NEMOH 
    %         solution, geometryCallbacks is then defined::
    %
    %             geometryCallbacks = ...
    %               struct('existing', @WecOptLib.experimental.callbacks.geometry.existingNEMOH, ...
    %                      'mygeom', @myGeom)
    %
    %
    %     staticModelCallback (function handle):
    %         (ABSTRACT) A function handle for a function that takes a 
    %         Hydro object and returns an intermediate struct that will be 
    %         passed to the input of dynamicModelCallback. The signature 
    %         of the callback function is as follows::
    %
    %             static = myStaticModel(hydro)
    %
    %
    %     dynamicModelCallback (function handle):
    %         (ABSTRACT) A function handle for a function that takes the 
    %         result of staticModelCallback, a Hydro object and a SeaState 
    %         object and returns a Motion object. An example of the 
    %         callback function is as follows::
    %
    %             function motion = myDynamicModel(static, hydro, seaState)
    %                 import WecOptLib.experimental.types.Motion
    %                 ...
    %                 motion = Motion(vars)
    %             end
    %           
    %
    %     controllerCallbacks (struct of function handles): 
    %         (ABSTRACT) A struct of function handles where each function 
    %         should take a Motion and a SeaState object and return a 
    %         Perfomance object. For instance, to apply the following 
    %         function::
    %
    %             function performace = myController(motion, seaState)
    %                 import WecOptLib.experimental.types.Performance
    %                 ...
    %                 performace = Performance(vars)
    %             end
    %         
    %         with the name 'mycontrol', define::
    %
    %             controllerCallbacks = struct('mycontrol', @myController)
    %
    %     aggregationHook (function handle): 
    %         (OPTIONAL) A function handle for a function which aggregates
    %         the outputs from multiple sea-states. It takes all of the
    %         properties of the DefaultDevice class and the given SeaState
    %         object as input and the result will be added to the 
    %         aggregation property of DefaultDevice. An example function 
    %         with the required signature is shown below::
    %
    %             function out = aggregate(seastate, hydro, motions, performances)
    %                 p = performances.toStruct()
    %                 out.pow = sum([p.pow])
    %             end
    %
    %
    
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
    
    properties (Abstract)
        
        geometryCallbacks
        staticModelCallback
        dynamicModelCallback
        controllerCallbacks
        % aggregationHook (optional)
        
    end
    
    methods
        
        function devices = makeDevices(obj, geomParams,          ...
                                            controlParams,       ...
                                            modelParams)
            % Create an m x n array of DefaultDevice objects for a given
            % set of geometry and controller configurations.
            %
            % Arguments:
            %     geomParams (array of struct)
            %     controlParams (array of struct)
            %     modelParams (optional array of struct)
            %
            % Returns:
            %    array of :mat:class:`+WecOptLib.+experimental.Device`:
            %        An array of Device objects with chosen geometries 
            %        along the first dimension, the chosen controllers 
            %        along the second and chosen model parameters along
            %        the third (if supplied).
            %
            
            if ~isfield(geomParams, "type")
                error("geomParams must have field 'type' defined")
            end
              
            if ~isfield(controlParams, "type")
                error("controlParams must have field 'type' defined")
            end
            
            if ~isfield(geomParams, "params")
                geomParams(1).params = [];
            end
              
            if ~isfield(controlParams, "params")
                controlParams(1).params = [];
            end
            
            if nargin == 3
                
                devices = obj.iterateGeometries(geomParams,    ...
                                                controlParams);
                return
                
            end
            
            if ~isfield(controlParams, "params")
                error("modelParams must have field 'params' defined")
            end
      
            for k = length(modelParams)
            
                modelParam = modelParams(k).params;
                devices(:, :, k) = obj.iterateGeometries(geomParams,    ...
                                                         controlParams, ...
                                                         modelParam);
                                                     
            end
            
        end
        
        function devices = recoverDevices(obj)
            % Recover all simulations from devices assosiated to this
            % blueprint.
            %
            % This can be useful if an optimisation has been run in 
            % parallel mode, where any new devices will not be stored.
            %
            % Returns:
            %    array of :mat:class:`+WecOptLib.+experimental.Device`:
            %        An array of Device objects
            %
            
            
            import WecOptLib.experimental.Device
            
            deviceDirs = WecOptLib.utils.getFolders(obj.folder,  ...
                                                    "absPath", true);
            n = length(deviceDirs);

            for i = 1:n
                dir = deviceDirs{i};
                devices(i) = load(fullfile(dir, 'device.mat')).obj;
            end
            
        end
        
    end
    
    methods (Access=private)
        
        function devices = iterateGeometries(obj, geomParams,       ...
                                                  controlParams,    ...
                                                  modelParam)
            
            devices = [];
            
            for i = 1:length(geomParams)
                
                geomType = geomParams(i).type;
                
                if isempty(geomParams(i).params)
                    geomParam = {};
                else
                    geomParam = geomParams(i).params;
                end
                
                geometryCB = obj.geometryCallbacks.(geomType);
                hydro = geometryCB(obj.folder, geomParam{:});
                
                if ~isa(hydro, "WecOptLib.experimental.types.Hydro")
                    errStr = "The geometry model must return a " +  ...
                             "Hydro object";
                    error("WecOptTool:Blueprint:NotHydro", errStr)
                end
                
                if nargin == 3
                
                    jdevices = obj.iterateControllers(hydro,            ...
                                                      geomType,         ...
                                                      geomParam,        ...
                                                      controlParams);
                
                else
                
                    jdevices = obj.iterateControllers(hydro,            ...
                                                      geomType,         ...
                                                      geomParam,        ...
                                                      controlParams,    ...
                                                      modelParam);
                                                  
                end
                                                 
                devices = [devices; jdevices];
                
            end
            
        end
        
        function devices = iterateControllers(obj, hydro,           ...
                                                   geomType,        ...
                                                   geomParam,       ...
                                                   controlParams,   ...
                                                   modelParam)
            
            import WecOptLib.experimental.Device
            
            % Setting of aggregationHook is optional
            if isprop(obj, "aggregationHook")
                aggregationHook = obj.aggregationHook;
            else
                aggregationHook = [];
            end
            
            for i = 1:length(controlParams)
                
                controlType = controlParams(i).type;
                
                if isempty(controlParams(i).params)
                    controlParam = {};
                else
                    controlParam = controlParams(i).params;
                end
                    
                controllerCB = obj.controllerCallbacks.(controlType);
                
                if nargin == 5
                   
                    devices(i) = Device(obj.folder,                 ...
                                        hydro,                      ...
                                        obj.staticModelCallback,    ...
                                        obj.dynamicModelCallback,   ...
                                        controllerCB,               ...
                                        aggregationHook,            ...
                                        geomType,                   ...
                                        geomParam,                  ...
                                        controlType,                ...
                                        controlParam);
                                    
                else

                    devices(i) = Device(obj.folder,                 ...
                                        hydro,                      ...
                                        obj.staticModelCallback,    ...
                                        obj.dynamicModelCallback,   ...
                                        controllerCB,               ...
                                        aggregationHook,            ...
                                        geomType,                   ...
                                        geomParam,                  ...
                                        controlType,                ...
                                        controlParam,               ...
                                        modelParam);
                                    
                end

            end
            
        end
            
    end
    
end
