function value = readConfig(key)
%READCONFIG Read the value for the given key in the config file

    WOTDataPath = WecOptLib.utils.getUserPath();
    
    if ~exist(WOTDataPath, 'dir')
        error("WecOptTool user directory does not exist")
    end
    
    configPath = fullfile(WOTDataPath, 'config.json');
    
    if ~exist(configPath, 'file')
        error("WecOptTool config file does not exist")
    end
    
    config = jsondecode(fileread(configPath));
    
    if ~isfield(config, key)
        error("Config file does contain the given key")
    end
    
    value = config.(key);
    
end

