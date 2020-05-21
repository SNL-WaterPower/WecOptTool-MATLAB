classdef (Abstract) Solver < AutoFolder
    
    methods (Abstract)
       hydro = solveMesh(obj, mesh)
    end
    
end
