function [powPerFreq, freqs] = damping(obj, RM3)
    % DAMPING Damping control
    %   Returns power per frequency and frequency bins
    %
    % References:
    %    Falnes, J., Ocean Waves and Oscillating Systems, 
    %      Cambridge University Press, 2002
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
 
    % Frequencies
    freqs = RM3.w;

    % Max Power for a given Damping Coeffcient [Falnes 2002 (p.51-52)]
    P_max = @(b) -0.5*b*sum(abs(RM3.F0./(RM3.Zi+b)).^2);
    % Optimize the linear damping coeffcient(B)
    B_opt = fminsearch(P_max, max(real(RM3.Zi)));
    
    % Power per frequency at optimial damping?
    powPerFreq = 0.5*B_opt *(abs(RM3.F0 ./ (RM3.Zi + B_opt)).^2);
        
end
