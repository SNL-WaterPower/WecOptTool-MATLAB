classdef (Abstract) Geometry < AutoFolder
    
    methods (Abstract)
       mesh = makeMesh(obj, geomType, geomParams)
    end
    
end
