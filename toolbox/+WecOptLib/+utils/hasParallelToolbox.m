function result = hasParallelToolbox()
%HASPARALLELTOOLBOX Is the Parallel Computing Toolbox installated?

    parallelToolboxLicense = license('test', "Distrib_Computing_Toolbox");

    addons = matlab.addons.installedAddons();
    iParallelToolbox = find(addons.Name == "Parallel Computing Toolbox");
    parallelToolboxInstalled = addons.Enabled(iParallelToolbox);
       
    result = parallelToolboxLicense && parallelToolboxInstalled;
    
end

