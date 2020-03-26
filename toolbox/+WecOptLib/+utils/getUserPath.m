function [WOTDataPath] = getUserPath()
%GETUSERPATH Return path to WecOptTool user data directory
    if ispc
        appDataPath = getenv('APPDATA');
        WOTDataPath = fullfile(appDataPath, 'WecOptTool');
    else
        appDataPath = getenv('HOME');
        WOTDataPath = fullfile(appDataPath, '.wecopttool');
    end
end

