function [srcRootPath] = getSrcRootPath()
%getSrcRootPath Return path to WecOptTool src code root directory
    p = mfilename('fullpath');
    [pDir, ~, ~] = fileparts(p);
    parts = strsplit(pDir, filesep);
    srcRootPath = fullfile(parts{1:end-3});
end

