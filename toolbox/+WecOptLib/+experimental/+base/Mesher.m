classdef (Abstract) Mesher < WecOptLib.experimental.base.AutoFolder
    
    methods (Abstract)
       mesh = makeMesh(obj, geomType, geomParams)
    end
    
end
