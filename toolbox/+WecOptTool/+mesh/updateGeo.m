function [outname,filetext] = updateGeo(geofn, varinames, varivals, outdir)
    % updateGeo updates a .geo file to be read by gmsh
    %
    % TODO
    
    [fp, fn, fs] = fileparts(geofn);
    if nargin < 4
        outdir = fp;
    end
    
    % read template file
    fidi = fopen(geofn,'r');
    filetext = fread(fidi,'*char')';
    fclose(fidi);
    
    %%

    
    % replace # symbols with variable values
    for ii = 1:length(varinames)
        expr = sprintf('%s = [+-]?\\d+\\.?\\d*;\\n',varinames{ii});
        newstr = sprintf('%s = %f;\\n',varinames{ii}, varivals{ii});
        filetext = regexprep(filetext,expr,newstr);
    end
    
    % write new file
    outname = fullfile(outdir,sprintf('%s_new%s',fn,fs));
    fido  = fopen(outname,'w');
    fprintf(fido,'%s',filetext);
    fclose(fido);
    
end