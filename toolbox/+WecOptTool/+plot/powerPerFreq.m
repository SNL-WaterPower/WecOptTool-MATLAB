function powerPerFreq(device)
    %POWERPERFREQ
    
    if isempty(device.seaState)
        return
    end
    
    % Number of Sea-States
    NSS = length(device.seaState);
    
    multiSeaState = false;
    if NSS>1
        multiSeaState = true;
    end    
    
    figure
    
    if multiSeaState
    
        hold on

        for i = 1 : NSS
            
            freq = device.motions(i).w;
            powPerFreq = device.performances(i).powPerFreq;
            plot(freq, powPerFreq,'DisplayName',int2str(i))

        end

        legend()
        
    else
        
        freq = device.motions(1).w;
        powPerFreq = device.performances(1).powPerFreq;
        length(powPerFreq)
        length(freq)
        plot(freq, powPerFreq)
        
    end
        
    xlabel('Frequency [$\omega$]','Interpreter','latex')
    ylabel('Power [$W]$','Interpreter','latex')
    grid
    
end
