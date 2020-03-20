function [powPerFreq, freq] = pseudoSpectral(obj, motion)
    % PSEUDOSPECTRAL Pseudo spectral control
    %   Returns power per frequency and frequency bins
    
    import WecOptLib.models.RM3.*
    
    % Fix random seed <- Do we want this???
    rng(1);
    
    % Reformulate equations of motion
    motion = getPSCoefficients(motion);
    
    % Add phase realizations
    n_ph_avg = 5;
    ph_mat = 2 * pi * rand(length(motion.w), n_ph_avg); 
    n_ph = size(ph_mat, 2);
    
    freq = motion.W;
    n_freqs = length(freq);
    powPerFreqMat = zeros(n_ph, n_freqs);
    
    for ind_ph = 1 : n_ph
        
        ph = ph_mat(:, ind_ph);
        [~, phasePowPerFreq] = getPSPhasePower(motion, ph);
        
        for ind_freq = 1 : n_freqs
            powPerFreqMat(ind_ph, ind_freq) = phasePowPerFreq(ind_freq);
        end
        
    end
    
    powPerFreq = mean(powPerFreqMat);
    
end