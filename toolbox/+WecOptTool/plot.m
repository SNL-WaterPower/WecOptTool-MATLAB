function plot(study)
    % PLOT Plots frequency vs. power for optimized study geometry
    
    disp("Generating plot...")
    
    RM3Device = WecOptLib.models.RM3.DeviceModel();
    [~, etc] = RM3Device.getPower(study.spectra,                    ...
                                  study.controlType,                ...
                                  study.geomMode,                   ...
                                  study.out{1},                     ...
                                  study.controlParams);

    
    figure
    hold on

    for i = 1 : length(etc.powPerFreq)

        powPerFreq = etc.powPerFreq{i};
        freq = etc.freq{i};
        plot(freq, powPerFreq)

    end
    
end
