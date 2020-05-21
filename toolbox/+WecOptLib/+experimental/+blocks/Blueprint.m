classdef (Abstract) Blueprint
    
    properties (Abstract)
        Geometries
        Model
        Controllers
    end
    
    methods
        
        function obj = Blueprint()
            
            import WecOptLib.experimental.blocks.*
            
            fn = fieldnames(obj.Geometries);
            
            for k = 1:numel(fn)
                
                if ~isa(obj.Geometries.(fn{k}),     ...
                        'WecOptLib.experimental.blocks.Geometry')
                    
                    errStr = "Geometry option " + fn + " is not " + ...   
                             "of Geometry type";
                    error("WecOptLib:Blueprint:NotGeometry", errStr)
                    
                end
            end
            
            if ~isa(obj.Model,     ...
                    'WecOptLib.experimental.blocks.Model')
                
                errStr = "Property Model must be of Model type";
                error("WecOptLib:Blueprint:NotModel", errStr)
                
            end
            
            fn = fieldnames(obj.Controllers);
            
            for k = 1:numel(fn)
                
                if ~isa(obj.Controllers.(fn{k}),    ...
                        'WecOptLib.experimental.blocks.Control')
                    
                    errStr = "Control option " + fn + " is not " + ...   
                             "of Control type";
                    error("WecOptLib:Blueprint:NotControl", errStr)
                    
                end
                
            end
            
        end
        
        function devices = makeDevices(obj, geomTypes,         ...
                                            geomParams,        ...
                                            controlTypes)
            
            import  WecOptLib.experimental.shared.Device
            
            if ~iscell(geomTypes)
                geomTypes = {geomTypes};
                geomParams = {geomParams};
            end
            
            if ~iscell(controlTypes)
                controlTypes = {controlTypes};
            end
            
            model = obj.Model();
            
            for i = 1:length(geomTypes)
                
                geomType = geomTypes{i};
                geomParam = geomParams{i};
                
                Geometry = obj.Geometries.(geomType);
                geometry = Geometry();
                hydro = geometry.getHydro(geomParam);
                
                for j = 1:length(controlTypes)
                    
                    controlType = controlTypes{i};
                    Controller = obj.Controllers.(controlType);
                    controller = Controller();
            
                    devices(i, j) = Device(hydro, model, controller);
                    
                end
                
            end
            
        end
        
    end
    
end
