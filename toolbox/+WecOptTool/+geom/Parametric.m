classdef Parametric < WecOptTool.geom.AbsGeom
    
    properties
        geomMode = 'parametric'
        geomLowerBound
        geomUpperBound
        geomX0
    end
    
    methods
    
        function obj = Parametric(x0, upperBound, lowerBound)
             
            obj = obj@WecOptTool.geom.AbsGeom();
            obj.geomLowerBound = upperBound;
            obj.geomUpperBound = lowerBound;
            obj.geomX0 = x0;
        
        end
    
    end

end

