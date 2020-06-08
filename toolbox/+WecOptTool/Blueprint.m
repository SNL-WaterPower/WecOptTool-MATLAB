classdef (Abstract) Blueprint < WecOptTool.base.AutoFolder
    % Abstract class for creating a new WEC blueprint where multiple  
    % geometries and controllers can be added to the blueprint alongside 
    % the model used to describe the WECs motion.
    %
    % A concrete implementation of the Blueprint class is defined as
    % follows::
    %
    %     classdef MyWEC < WecOptTool.Blueprint
    %
    % The abstract properties ``geometryCallbacks``, 
    % ``staticModelCallback``, ``dynamicModelCallback`` and 
    % ``controllerCallbacks`` must be defined, as described below.
    %
    % Arguments:
    %     baseFolder (optional string):
    %         Path to parent of data storage folder. If supplied, 
    %         automatic file cleanup on object descruction is disabled.
    % 
    % Attributes:
    %     folder (string): path to data storage folder
    %     geometryCallbacks (struct of function handles):
    %         (ABSTRACT) A struct of function handles where each function 
    %         should take a folder path as the first input argument, an 
    %         arbitrary number of additional inputs and return a 
    %         :mat:class:`+WecOptTool.+types.Hydro` object. For instance, 
    %         to include the following function,::
    %
    %             function hydro = myGeom(folder, sizeA, sizeB)
    %                 ...
    %                 hydro = WecOptTool.types("Hydro", varsStruct)
    %             end
    %
    %         and use one pre-defined callback for an existing NEMOH 
    %         solution, the geometryCallbacks property should be defined
    %         as::
    %
    %             geometryCallbacks = ...
    %               struct('existing', @WecOptTool.callbacks.geometry.existingNEMOH, ...
    %                      'mygeom', @myGeom)
    %
    %
    %     staticModelCallback (function handle):
    %         (ABSTRACT) A function handle for a function that takes a 
    %         Hydro object, an arbitrary number of additional inputs, and 
    %         returns an intermediate struct that will be passed to the 
    %         input of dynamicModelCallback. The signature of the callback 
    %         function is as follows::
    %
    %             static = myStaticModel(hydro, arg1, arg2)
    %
    %         Note, the additional arguments to the staticModelCallback and
    %         dynamicModelCallback functions should be the same (even if
    %         they go unused).
    %
    %     dynamicModelCallback (function handle):
    %         (ABSTRACT) A function handle for a function that takes the 
    %         result of staticModelCallback, a Hydro object, SeaState 
    %         object, an arbitrary number of additional inputs, and 
    %         returns a :mat:class:`+WecOptTool.+types.Motion` object. An 
    %         example of the callback function is as follows::
    %
    %             function motion = myDynamicModel(static, hydro, seaState, arg1, arg2)
    %                 ...
    %                 motion = WecOptTool.types("Motion", varsStruct)
    %             end
    %           
    %         Note, the additional arguments to the staticModelCallback and
    %         dynamicModelCallback functions should be the same (even if
    %         they go unused).
    %
    %     controllerCallbacks (struct of function handles): 
    %         (ABSTRACT) A struct of function handles where each function 
    %         should take a Motion object and return a 
    %         :mat:class:`+WecOptTool.+types.Perfomance` object. For 
    %         instance, to apply the following function::
    %
    %             function performace = myController(motion)
    %                 ...
    %                 performace = WecOptTool.types("Performance", vars)
    %             end
    %         
    %         with the name 'mycontrol', define::
    %
    %             controllerCallbacks = struct('mycontrol', @myController)
    %
    %     aggregationHook (function handle): 
    %         (OPTIONAL) A function handle for a function which aggregates
    %         the outputs from multiple sea-states. It takes the
    %         :mat:class:`+WecOptTool.+types.SeaState` object, 
    %         :mat:class:`+WecOptTool.+types.Hydro` object, array of
    %         :mat:class:`+WecOptTool.+types.Motion` objects and array of
    %         :mat:class:`+WecOptTool.+types.Performance` objects, which
    %         relate to the outputs of the last call to 
    %         :mat:func:`+WecOptTool.Device.simulate`. The result of the
    %         given callback will be added to the aggregation property of 
    %         Device. An example function with the required signature is 
    %         shown below::
    %
    %             function out = aggregate(seastate, hydro, motions, performances)
    %                 p = performances.toStruct()
    %                 out.pow = sum([p.pow])
    %             end
    %
    % --
    %
    % Blueprint Properties:
    %     geometryCallbacks - struct of functions which make Hydro objects
    %     staticModelCallback - callback for creating equations of motion
    %                           not dependent on the sea-state.
    %     dynamicModelCallback - callback for creating equations of motion
    %                            which are dependent on the sea-state and
    %                             produce a Motion object
    %     controllerCallbacks - struct of functions which make Performance
    %                           objects
    %
    % Blueprint Methods:
    %     makeDevices - Create an m x n X l array of Device objects for a 
    %                   given set of geometry, model and controller 
    %                   configurations.
    %     recoverDevices - Recover all simulations from devices assosiated 
    %                      to the blueprint.
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
    
    properties (Abstract)
        
        geometryCallbacks
        staticModelCallback
        dynamicModelCallback
        controllerCallbacks
        
    end
    
    methods
        
        function devices = makeDevices(obj, geomParams,          ...
                                            controlParams,       ...
                                            modelParams)
            % Create an m x n X l array of Device objects for a given set 
            % of geometry, model and controller configurations.
            %
            % All arguments accept a struct array with the fields type and
            % params, with the following meaning:
            %
            %     * type: the name of the geometry algorith to use. Only
            %             required for geomParams and modelParams and
            %             should match the field names used in the 
            %             geometryCallbacks and controllerCallbacks
            %             properties.
            %     * params: params to pass to the algorithms in a cell 
            %               array. Required for the modelParams argument,
            %               optional otherwise. All given parameters 
            %               should match the additional arguments given
            %               in the callbacks.
            %
            % Arguments:
            %     geomParams (array of struct):
            %          Selected geometry algorithms and parameters to pass 
            %     controlParams (array of struct):
            %          Selected controller algorithms and parameters to 
            %          pass 
            %     modelParams (optional array of struct):
            %          Parameters to pass to the motion model
            %
            % Returns:
            %    array of :mat:class:`+WecOptTool.Device`:
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
            % Recover all simulations from devices assosiated to the
            % blueprint.
            %
            % This can be useful if an optimisation has been run in 
            % parallel mode, where any new devices will not be stored.
            %
            % Returns:
            %    array of :mat:class:`+WecOptTool.Device`:
            %        An array of Device objects
            %
            
            deviceDirs = WecOptLib.utils.getFolders(obj.folder,  ...
                                                    "absPath", true);
            nDirs = length(deviceDirs);
            nDevices = 1;

            for i = 1:nDirs
                dir = deviceDirs{i};
                fileName = fullfile(dir, 'device.mat');
                if isfile(fileName)
                    devices(nDevices) = load(fileName).obj;
                    nDevices = nDevices + 1;
                end
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
                
                if ~isa(hydro, "WecOptTool.types.Hydro")
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
            
            import WecOptTool.Device
            
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
