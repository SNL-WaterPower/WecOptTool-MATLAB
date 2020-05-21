classdef (Abstract) Model
    
    methods (Abstract)
       static = getStatic(obj, hydro)
       dynamic = getDynamic(obj, static, hydro, S)
    end
    
end
