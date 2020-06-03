classdef (Abstract) Solver < WecOptLib.experimental.base.AutoFolder
    
    methods (Abstract)
       mesh = getHydro(obj, meshes, varagin)
    end
    
end
