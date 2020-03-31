function [combined, licensed, installed] = hasParallelToolbox()
%HASPARALLELTOOLBOX Is the Parallel Computing Toolbox available?

    licensed = license('test', "Distrib_Computing_Toolbox");
    addons = matlab.addons.installedAddons();
    iParallelToolbox = addons.Name == "Parallel Computing Toolbox";
    installed = addons.Enabled(iParallelToolbox);
    
    % Check for parallel functions used by WecOptTool
    parFunctions = ["getCurrentWorker"];
    hasAllFunctions = true;
    
    for func = parFunctions
   
        isFunction = exist(func,'file');
        if isFunction ~= 2
            hasAllFunctions = false;
        else
            fileLoc = which('getCurrentWorker');
            hasAllFunctions = isfile(fileLoc);            
        end
        
    end
    
    combined = licensed && installed && hasAllFunctions;
    
end

