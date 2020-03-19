function [powPerFreq, freqs] = complexConjugate(obj, RM3)
    % COMPLEXCONJUGATE Complex conjugate control
    %   Returns power per frequency and frequency bins

    freqs = RM3.w;
    
    % Calculate Impedance
    Z3 = RM3.B33 + RM3.D3 + RM3.Bf + 1i * ( ...
                freqs .* (RM3.mass1 + RM3.A33) - RM3.K3 ./ freqs);
    Z9 = RM3.B99 + RM3.D9 + RM3.Bf + 1i * ( ...
                freqs .* (RM3.mass2 + RM3.A99) - RM3.K9 ./ freqs);
    Zc = RM3.B39 + 1i * RM3.w .* RM3.A39;

    Z0 = Z3 + Z9 + 2*Zc;
    Zi = (Z3.*Z9 - Zc.^2) ./ Z0;

    F0 = (RM3.E3.*(Z9+Zc) - RM3.E9 .* (Z3 + Zc)) ./ Z0;
    
    % Power per frequency
    powPerFreq = abs(F0) .^ 2 ./ (8 * real(Zi));
    
    %TODO: Determine if this code is useful going forward
%     Ur = F0 ./ (2 * real(Zi));
%     Sr = -1i * Ur ./ RM3.w;
%     Fl = conj(Zi) .* Ur;
% 
%     tkp = linspace(0, 2*pi/(mean(diff(RM3.w))), 4*(length(RM3.w)));
% 
%     exp_mat = exp(1i * RM3.w * tkp);
%     srt = real(Sr .' * exp_mat);
%     urt = real(Ur .' * exp_mat);
%     Flt = real(Fl .' * exp_mat);

end