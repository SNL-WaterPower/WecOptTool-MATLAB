function [srcRootPath] = getSrcRootPath()
%getSrcRootPath Return path to WecOptTool src code root directory
    p = mfilename('fullpath');
    [pDir, ~, ~] = fileparts(p);
    parts = strsplit(pDir, filesep);
    srcRootPath = fullfile(parts{1:end-3});
    
    % Linux requires a leading slash
    if ~ispc
        srcRootPath = append(filesep, srcRootPath);
    end
    
end

