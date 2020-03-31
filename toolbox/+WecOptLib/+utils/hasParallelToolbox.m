function [combined, licensed, installed] = hasParallelToolbox()
%HASPARALLELTOOLBOX Is the Parallel Computing Toolbox available?

    licensed = license('test', "Distrib_Computing_Toolbox");
    addons = matlab.addons.installedAddons();
    iParallelToolbox = addons.Name == "Parallel Computing Toolbox";
    installed = addons.Enabled(iParallelToolbox);
    
    % Check for used parallel functions
    parFunctions = ["getCurrentWorker"];
    hasAllFunctions = true;
    
    for func = parFunctions
        toggled = exist(func,'file');
        if toggled ~= 2
            hasAllFunctions = false;
        end
    end
    
    combined = licensed && installed && hasAllFunctions;
    
end

