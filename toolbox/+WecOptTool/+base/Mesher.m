classdef (Abstract) Mesher < WecOptTool.base.AutoFolder
    
    methods (Abstract)
       mesh = makeMesh(obj, varagin)
    end
    
end
