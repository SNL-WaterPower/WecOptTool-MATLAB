classdef Existing < WecOptTool.geom.AbsGeom
    
    properties
        geomMode = 'existing'
        geomLowerBound
        geomUpperBound
        geomX0
    end
    
    methods
    
        function obj = Existing(nemohRunDirectory)
             
            obj = obj@WecOptTool.geom.AbsGeom();
            obj.geomX0 = nemohRunDirectory;
            
        end
    
    end

end

