function writeConfig(key, value)
%WRITECONFIG Add given key with given value to config file

    % Check if the user data directory exists and make if necessary
    WOTDataPath = WecOptLib.utils.getUserPath();
    
    if ~exist(WOTDataPath, 'dir')
       mkdir(WOTDataPath)
    end
    
    % Check if the config file exists and read
    configPath = fullfile(WOTDataPath,'config.json');
    
    if exist(configPath, 'file')
        config = jsondecode(fileread(configPath));
    else
        config = struct(key, value);
    end
    
    if strcmp(value, "")
        config = rmfield(config, key);
    else
        config.(key) = value;
    end
    
    % Convert to JSON text and save
    jsonConfig = jsonencode(config);
    fid = fopen(configPath, 'w');
    fprintf(fid, '%s', jsonConfig);
    fclose(fid);
    
end

