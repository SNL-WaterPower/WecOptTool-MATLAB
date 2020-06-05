function hydro = solver(solverName, folder, varargin)

    fullQName = "WecOptTool.solver." + solverName;
    solverHandle = str2func(fullQName);
    solver = solverHandle(folder);
    hydro = solver.getHydro(varargin{:});

end
