function result = hasParallelToolbox()
%HASPARALLELTOOLBOX Is the Parallel Computing Toolbox licensed and 
%    installated?

    licensed = license('test', "Distrib_Computing_Toolbox");

    addons = matlab.addons.installedAddons();
    iParallelToolbox = find(addons.Name == "Parallel Computing Toolbox");
    installed = addons.Enabled(iParallelToolbox);
    
    % 0-not exists or 2- is a file; 
    toggled = exist('getCurrentWorker','file');
    if toggled == 2
        toggled=true;
    end
    
    result = [licensed, installed, toggled]; 
end

