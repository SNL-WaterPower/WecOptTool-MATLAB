function [licensed, installed] = hasParallelToolbox()
%HASPARALLELTOOLBOX Is the Parallel Computing Toolbox licensed and 
%    installated?

    licensed = license('test', "Distrib_Computing_Toolbox");

    addons = matlab.addons.installedAddons();
    iParallelToolbox = find(addons.Name == "Parallel Computing Toolbox");
    installed = addons.Enabled(iParallelToolbox);
         
end

