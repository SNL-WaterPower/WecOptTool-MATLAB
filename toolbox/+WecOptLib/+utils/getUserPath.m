function [WOTDataPath] = getUserPath()
%GETUSERPATH Return path to WecOptTool user data directory
    if ispc
        appDataPath = getenv('APPDATA');
        WOTDataPath = [appDataPath filesep 'WecOptTool'];
    else
        appDataPath = getenv('HOME');
        WOTDataPath = [appDataPath filesep '.wecopttool'];
    end
end

