classdef Scalar < WecOptTool.geom.AbsGeom
    
    properties
        geomMode = 'scalar'
        geomLowerBound
        geomUpperBound
        geomX0
    end
    
    methods
    
        function obj = Scalar(x0, upperBound, lowerBound)
             
            obj = obj@WecOptTool.geom.AbsGeom();
            obj.geomLowerBound = upperBound;
            obj.geomUpperBound = lowerBound;
            obj.geomX0 = x0;
        
        end
    
    end

end

