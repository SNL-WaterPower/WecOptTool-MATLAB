function result = hasParallelToolbox()
%HASPARALLELTOOLBOX Is the Parallel Computing Toolbox installated?

    parallelToolboxLicense = license('test', "Distrib_Computing_Toolbox");

    installedProducts = ver;
    installedNames = {installedProducts(:).Name};
    parallelToolboxInstalled = false;
    
    for name = installedNames
        if contains(name, "Parallel Computing Toolbox")
            parallelToolboxInstalled = true;
            break
        end
    end
    
    result = parallelToolboxLicense && parallelToolboxInstalled;
    
end

