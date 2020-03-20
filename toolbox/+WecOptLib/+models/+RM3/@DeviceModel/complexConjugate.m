function [powPerFreq, freqs] = complexConjugate(obj, RM3)
    % COMPLEXCONJUGATE Complex conjugate control
    %   Returns power per frequency and frequency bins
  
    % Frequencies
    freqs = RM3.w;
    
    % Maximum absorbed power
    % Note: Re{Zi} = Radiation Damping Coeffcient
    powPerFreq = abs(RM3.F0) .^ 2 ./ (8 * real(RM3.Zi));

end
