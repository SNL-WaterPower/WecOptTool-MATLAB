function plot(study)
    % PLOT Plots frequency vs. power for optimized study geometry
    
    disp("Generating plot...")
    
    RM3Device = WecOptLib.models.RM3.DeviceModel(study.nemohDir);
    [~, etc] = RM3Device.getPower(study.spectra,                    ...
                                  study.controlType,                ...
                                  study.geomMode,                   ...
                                  study.out{1},                     ...
                                  study.controlParams);

    % Power vs Frequency Plot
    WecOptLib.plots.powerPerFreq(study.spectra, etc);
    
end
