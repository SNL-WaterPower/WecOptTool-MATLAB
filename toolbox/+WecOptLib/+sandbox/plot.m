function plot
    %PLOT
    
    import WecOptLib.models.RM3.*
    
    S = WecOptLib.tests.data.exampleSpectrum();
    S.ph = rand(length(S.w),1)* 2 * pi;
    [S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
    delta_Zmax = 1;
    delta_Fmax = 1e9;
    
    RM3Device = DeviceModel();
    [pow, etc] = RM3Device.getPower(S,                          ...
                                    'PS',                       ...
                                    'scalar',                   ...
                                    1.,                         ...
                                    [delta_Zmax, delta_Fmax]);

    powPerFreq = etc.powPerFreq{1};
    freq = etc.freq{1};
    
    figure
    plot(freq, powPerFreq)
    
end
    
