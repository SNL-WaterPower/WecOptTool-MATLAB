classdef Device < handle
    
    properties 
        hydro
        motion
        performance
    end
    
    properties (Access = private)
        model
        controller
        staticMotion
    end
    
    methods
        
        function obj = Device(hydro, model, controller)
            obj.hydro = hydro;
            obj.model = model;
            obj.controller = controller;
            obj.staticMotion = model.getStatic(hydro);
        end
        
        function simulate(obj, S)
            
           obj.motion = obj.model.getDynamic(obj.staticMotion, ...
                                             obj.hydro,        ...
                                             S);
            
            fn = fieldnames(obj.staticMotion);
            for i = 1:length(fn)
                obj.motion.(fn{i}) = obj.staticMotion.(fn{i});
            end
            
            obj.performance = obj.controller.getPerfomance(obj.motion, S);
                                
        end
    
    end
    
end
