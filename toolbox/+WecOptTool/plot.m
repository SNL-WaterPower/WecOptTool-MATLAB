function plot(study)
    % PLOT Plots frequency vs. power for optimized study geometry
    
    disp("Generating plot...")
    
    RM3Device = WecOptLib.models.RM3.DeviceModel();
    [~, etc] = RM3Device.getPower(study.spectra,                    ...
                                  study.controlType,                ...
                                  study.geomMode,                   ...
                                  study.out{1},                     ...
                                  study.controlParams);

    % Check if study run with 1 or multiple Sea-States  
    SS = study.spectra;
    % If SS dowes not have attributes w, S then multiple sea-states 
    if ~isfield(SS,'w') && ~isfield(SS,'S')
        % Spectra names for legend
        seaStateNames = fieldnames(study.spectra);
    end
    
    figure
    hold on

    for i = 1 : length(etc.powPerFreq)

        powPerFreq = etc.powPerFreq{i};
        freq = etc.freq{i};
        plot(freq, powPerFreq,'DisplayName',seaStateNames{i})

    end
    legend()
    xlabel('Frequency [$\omega$]','Interpreter','latex')
    ylabel('Power [$W]$','Interpreter','latex')
    grid
end
