function powerPerFreq(spectra, etc)
    %PLOTPOWER
    
    multi_state = false;
    
    if ~isfield(spectra,'w') && ~isfield(spectra,'S')
        seaStateNames = fieldnames(spectra);
        multi_state = true;
    end
    
    figure
    
    if multi_state
    
        hold on

        for i = 1 : length(etc.powPerFreq)

            powPerFreq = etc.powPerFreq{i};
            freq = etc.freq{i};
            plot(freq, powPerFreq,'DisplayName',seaStateNames{i})

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

