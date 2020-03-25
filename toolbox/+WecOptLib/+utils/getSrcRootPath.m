function [srcRootPath] = getSrcRootPath()
%getSrcRootPath Return path to WecOptTool src code root directory
    p = mfilename('fullpath');
    [pDir, ~, ~] = fileparts(p);
    srcRootPath = fullfile(pDir, '..', '..', '..');
end

