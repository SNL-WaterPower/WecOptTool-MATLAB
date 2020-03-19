function plot
    %PLOT
    
    import WecOptLib.models.RM3.*
    
    S = WecOptLib.tests.data.exampleSpectrum();
    S.ph = rand(length(S.w),1)* 2 * pi;
    [S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
    delta_Zmax = 10;
    delta_Fmax = 1e9;
    
    RM3Device = DeviceModel();
    
    [hydro, ~] = RM3Device.getHydrodynamics('scalar', 1.);
    
    motion = RM3Device.getMotion(S,                         ...
                                 hydro,                     ...
                                 'PS',                      ...
                                 [delta_Zmax, delta_Fmax]);
    
    motion = getPSCoefficients(motion);
    ph = 5.3208;
    [Pt_ph, P] = getPSPhasePower(motion, ph);
    
    figure
    plot(motion.W, P)
    
    assert(WecOptLib.utils.isClose(sum(P), abs(Pt_ph)))
    
end
    
