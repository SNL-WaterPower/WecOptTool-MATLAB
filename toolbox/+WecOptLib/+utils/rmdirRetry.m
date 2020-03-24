function rmdirRetry(dirPath)
    %RMDIRRETRY Calls rmdir with 's' option in a retry loop
    
    maxRetries = 59;
    nRetries = 0;
    
    while nRetries < maxRetries
        try
            rmdir(dirPath, 's');
            return
        catch
            pause(1)
            nRetries = nRetries + 1;
        end
    end
    
    rmdir(dirPath, 's');
    
end

