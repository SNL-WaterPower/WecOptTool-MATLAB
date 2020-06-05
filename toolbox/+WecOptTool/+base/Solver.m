classdef (Abstract) Solver < WecOptTool.base.AutoFolder
    
    methods (Abstract)
       mesh = getHydro(obj, meshes, varagin)
    end
    
end
