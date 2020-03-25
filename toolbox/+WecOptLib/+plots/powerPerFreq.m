function powerPerFreq(spectra, etc)
    %PLOTPOWER
    
    
    % Number of Sea-States
    NSS = length(spectra);
    
    multiSeaState = false;
    if NSS>1
        multiSeaState = true;
    end    
    
    figure
    
    if multiSeaState
    
        hold on

        for i = 1 : length(etc.powPerFreq)
            
            powPerFreq = etc.powPerFreq{i};
            freq = etc.freq{i};
            plot(freq, powPerFreq,'DisplayName',int2str(i))

        end

        legend()
        
    else
        
        powPerFreq = etc.powPerFreq{1};
        freq = etc.freq{1};
        plot(freq, powPerFreq)
        
    end
        
    xlabel('Frequency [$\omega$]','Interpreter','latex')
    ylabel('Power [$W]$','Interpreter','latex')
    grid
    
end

