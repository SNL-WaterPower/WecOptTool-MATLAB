function plot(study)
    % Plots frequency vs. power for optimized study geometry    
    import WecOptLib.models.RM3.*
    RM3Device = WecOptLib.models.RM3.DeviceModel();
    [pow, etc] = RM3Device.getPower(study.spectra,                    ...
                                    study.controlType,                ...
                                    study.geomMode,                   ...
                                    study.out{1},                     ...
                                    study.controlParams);

    powPerFreq = etc.powPerFreq{1};
    freq = etc.freq{1};
    
    figure
    plot(freq, powPerFreq)    
    
end
