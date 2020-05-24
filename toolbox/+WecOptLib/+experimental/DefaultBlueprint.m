classdef (Abstract) DefaultBlueprint < WecOptLib.experimental.base.Blueprint
    % Abstract class for creating a new WEC blueprint. Multiple geometries 
    % and controllers can be added to the blueprint alongside the dyanamic
    % model to describe the WECs motion (using the electrical circuit 
    % analogue).
    %
    % A concrete implementation of the Blueprint class is defined as
    % follows::
    %
    %     classdef MyWEC < WecOptLib.experimental.blocks.Blueprint
    %
    % The properties 'Model', 'Geometries' and 'Controllers' must also
    % be defined, as described below
    %
    % Attributes:
    %     Model (:mat:class:`+WecOptLib.experimental.blocks.Model`):
    %         A single Model class must be given, i.e. Model = MyModel
    %     Geometries (struct of :mat:class:`WecOptLib.experimental.blocks.Geometry):
    %         A struct with Geometry class values and identifying fields,
    %         i.e.::
    %
    %             Geometries = struct("geo1": MyFirstGeometry,    ...
    %                                 "geo2": MySecondGeometry)
    %
    %     Controllers (struct of :mat:class:`+WecOptLib.experimental.blocks.Control`): 
    %         A struct with Control classes values and identifying fields,
    %         i.e.::
    %
    %             Controllers = struct("CC": ComplexCongugate,    ...
    %                                  "D": Damping)
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
        
    end
    
    methods
        
        function devices = makeDevices(obj, geomTypes,         ...
                                            geomParams,        ...
                                            controlTypes)
                        
            if ~iscell(geomTypes)
                geomTypes = {geomTypes};
                geomParams = {geomParams};
            end
            
            if ~iscell(controlTypes)
                controlTypes = {controlTypes};
            end
                        
            devices = obj.iterateGeometries(geomTypes,  ...
                                            geomParams, ...
                                            controlTypes);
            
        end
        
        function devices = iterateGeometries(obj, geomTypes,  ...
                                                  geomParams, ...
                                                  controlTypes)
        
            devices = [];
                                              
            for i = 1:length(geomTypes)
                
                geomType = geomTypes{i};
                geomParam = geomParams{i};
                
                geometryCB = obj.geometryCallbacks.(geomType);
                hydro = geometryCB(geomParam);
                jdevices = obj.iterateControllers(hydro, controlTypes);
                
                devices = [devices; jdevices];
                
            end
            
        end
        
        function devices = iterateControllers(obj, hydro, controlTypes)
            
            import  WecOptLib.experimental.DefaultDevice
            
            for i = 1:length(controlTypes)
                    
                controlType = controlTypes{i};
                controllerCB = obj.controllerCallbacks.(controlType);

                devices(i) = DefaultDevice(hydro,                       ...
                                           obj.staticModelCallback,     ...
                                           obj.dynamicModelCallback,    ...
                                           controllerCB);

            end
            
        end
            
    end
    
end
