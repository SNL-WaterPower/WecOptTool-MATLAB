function [powSS] = damping(obj, RM3)
    % Returns total power and power per frequency
    
    % Calculate Impedance
    Z3 = RM3.B33 + RM3.D3 + RM3.Bf + 1i*(RM3.w.*(RM3.mass1 + RM3.A33) - RM3.K3./RM3.w);
    Z9 = RM3.B99 + RM3.D9 + RM3.Bf + 1i*(RM3.w.*(RM3.mass2 + RM3.A99) - RM3.K9./RM3.w);
    Zc = RM3.B39 + 1i * RM3.w .* RM3.A39;

    Z0 = Z3 + Z9 + 2*Zc;
    Zi = (Z3.*Z9 - Zc.^2) ./ Z0;  %Zi = matched Impedance?

    F0 = (RM3.E3.*(Z9+Zc) - RM3.E9.*(Z3+Zc))./Z0;

    % Optimize linear damping B over Impedance? 
    P_max = @(b) -0.5*b*sum(abs(F0./(Zi+b)).^2);
    B_opt = fminsearch(P_max, max(real(Zi)));
    
    % Power per frequency at optimial damping?
    Pabs = 0.5*B_opt *(abs(F0 ./ (Zi + B_opt)).^2);
    % Sea-state Power Total
    powSS=-1 * sum(Pabs);
    
    %TODO: Determine if this code is useful going forward
%     Ur = F0 ./ (2 * real(Zi));
%     Sr = -1i * Ur ./ RM3.w;
%     Fl = conj(Zi) .* Ur;
%         
%     tkp = linspace(0, 2*pi/(mean(diff(RM3.w))), 4*(length(RM3.w)));
%     exp_mat = exp(1i * RM3.w * tkp);
%     srt = real(Sr .' * exp_mat);
%     urt = real(Ur .' * exp_mat);
%     Flt = real(Fl .' * exp_mat);
end