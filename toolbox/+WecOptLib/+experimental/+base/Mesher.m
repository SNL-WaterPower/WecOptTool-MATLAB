classdef (Abstract) Mesher < WecOptLib.experimental.base.AutoFolder
    
    methods (Abstract)
       mesh = makeMesh(obj, varagin)
    end
    
end
