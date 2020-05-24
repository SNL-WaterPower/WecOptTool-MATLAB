classdef DefaultDevice < WecOptLib.experimental.base.Device
    
    properties 
        hydro
        motion
        performance
    end
    
    properties (Access = private)
        staticMotion
        dynamicModelCB
        controllerCB
    end
    
    methods
        
        function obj = DefaultDevice(hydro,                ...
                                     staticModelCallback,  ...
                                     dynamicModelCallback, ...
                                     controllerCallbBack)
                          
            obj.hydro = hydro;
            obj.staticMotion = staticModelCallback(hydro);
            obj.dynamicModelCB = dynamicModelCallback;
            obj.controllerCB = controllerCallbBack;
            
        end
        
        function simulate(obj, S)
            
           obj.motion = obj.dynamicModelCB(obj.staticMotion, ...
                                           obj.hydro,        ...
                                           S);
            
            fn = fieldnames(obj.staticMotion);
            for i = 1:length(fn)
                obj.motion.(fn{i}) = obj.staticMotion.(fn{i});
            end
            
            obj.performance = obj.controllerCB(obj.motion, S);
                                
        end
    
    end
    
end
