function [pow_ss] = pseudoSpectral(obj, motion)
    
    import WecOptLib.models.RM3.*
    
    % Reformulate equations of motion
    motion = getPSCoefficients(motion);
    
    n_ph_avg = 5; % number of phase realizations to average
    rng(1); % for consistency and allow to debug
    ph_mat = 2 * pi * rand(length(motion.w), n_ph_avg); % add phase realization
    n_ph = size(ph_mat, 2);
    %n_ph =1;
    Pt_mat = zeros(n_ph, 1);

    for ind_ph = 1: n_ph
        
        ph = ph_mat(:, ind_ph);
        [Pt_ph, ~] = getPSPhasePower(motion, ph);
        Pt_mat(ind_ph) = Pt_ph;

    end

    pow_ss = mean(Pt_mat);

end