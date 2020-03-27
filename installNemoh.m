function installNemoh(nemohPath)
%INSTALLNEMOH Add Nemoh executables path to WecOptTool
    
    % Check if the user data directory exists and make if necessary
    WOTDataPath = WecOptLib.utils.getUserPath();
    
    if ~exist(WOTDataPath, 'dir')
       mkdir(WOTDataPath)
    end
    
    % Check if the config file exists and read
    configPath = fullfile()WOTDataPath,'config.json');
    
    if exist(configPath, 'file')
        config = jsondecode(fileread(configPath));
        config.nemohPath = nemohPath;
    else
        config = struct('nemohPath', nemohPath);
    end
    
    % Convert to JSON text and save
    jsonConfig = jsonencode(config);
    fid = fopen(configPath, 'w');
    fprintf(fid, '%s', jsonConfig);
    fclose(fid);

end

