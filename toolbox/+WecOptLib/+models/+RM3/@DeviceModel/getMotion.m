
n RM3 = getMotion(obj, S, hydro, controlType, maxVals)
% RM3 = getMotion(S, hydro, controlType, geomMode, maxVals)
%
% Returns one Sea-state power given spectra, BEM response, geomMode,
%    and the max vals
%
% Inputs
%       S               wave spectra structure, with fields:
%           S.S         spectral energy distribution [m^2 s/rad]
%           S.w         frequency [rad/s]
%           S.ph        phasing
%           S.mu        weighting factor
%       hydro           hydro struct from Nemoh
%       controlType     choose control type for PTO:
%                           CC: complex conjugate (no constraints)
%                           PS: pseudo-spectral (with constraints)
%                           P: proportional damping
%       geomMode        choose mode for geometry definition; geometry
%                       inputs are passed in as string-value pairs, see
%                       RM3_getNemoh documentation for more info.
%                           scalar: single scaling factor lambda
%                           parametric: [r1, r2, d1, d2] parameters
%                           existing: pass existing NEMOH rundir
%       controlParams   if using the 'PS' control type, optional arguments 
%                       for deltaZmax and deltaFmax
%                           Note: to use the optional arguments, both must
%                           be provided
% Outputs
%       RM3           struct of components defining device motion
%
% References:
%    Falnes, J., Ocean Waves and Oscillating Systems, 
%      Cambridge University Press, 2002
%    Falnes, J.,“Wave-energy conversion through relative motion between two 
%      single-mode % oscillating bodies,” Journal of Offshore Mechanics 
%      and Arctic Engineering, vol. 121, no. 1, pp. 32–38, 1999. 
% Examples:
% 1) Using scalar input with CC control and scaling factor 1:
% motion = obj.getMotion(S,, hydro, controlType, maxVals);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set max values for PS control
if strcmp(controlType, 'PS') && length(maxVals) == 2
    delta_Zmax = maxVals(1);
    delta_Fmax = maxVals(2);
    RM3.delta_Zmax = delta_Zmax;
    RM3.delta_Fmax = delta_Fmax;
end

% Ignore tails of the spectra; return indicies of the vals>1% of max
iSpec = find(S.S > 0.01*max(S.S));
% Return column vector of all w between first/last indicies
iStart = min(iSpec);
iEnd   = max(iSpec);
iSkip  = 1;
w = S.w(iStart:iSkip:iEnd);
% Calculate w step-size
if length(iSpec) == 1
    dw = wStep;    
else    
    dw = mean(diff(S.w))*iSkip;   
end

% Get column vector S at same indicies as w (Removed interpolation). 
s = S.S(iStart:iSkip:iEnd);
% TODO: is interp needed? %s = interp1(S.w(:), S.S, w,'linear',0);
% Calculate wave amplitude
waveAmp = sqrt(2 * dw * s);
% Row vector of random phases?
ph = rand(length(s), 1);
% Wave height in frequency domain
eta_fd = waveAmp .* exp(1i*ph);
eta_fd = eta_fd(:);

% Mass
mass1 = hydro.Vo(1) * hydro.rho;
mass2 = hydro.Vo(2) * hydro.rho;


% Restoring
K3 = hydro.C(3,3,1) * hydro.g * hydro.rho;
K9 = hydro.C(3,3,2) * hydro.g * hydro.rho;

% Radiation impedance matrix: B + iwA
% A: Added Mass
% B: Damping 
B99 = interp1(hydro.w,squeeze(hydro.B(9, 9, :)),w,'linear',0) * hydro.rho .* w;
A99 = interp1(hydro.w,squeeze(hydro.A(9, 9, :)),w,'linear',0) * hydro.rho;

B39 = ((interp1(hydro.w,squeeze(hydro.B(3, 9, :)),w,'linear',0) + ...
    interp1(hydro.w,squeeze(hydro.B(9, 3, :)),w,'linear',0)) ./ 2) * hydro.rho .* w;
A39 = ((interp1(hydro.w,squeeze(hydro.A(3, 9, :)),w,'linear',0) + ...
    interp1(hydro.w,squeeze(hydro.A(9, 3, :)),w,'linear',0)) ./ 2) * hydro.rho;

B33 = squeeze(interp1(hydro.w,squeeze(hydro.B(3, 3, :)),w,'linear',0)) * hydro.rho .* w;
A33 = squeeze(interp1(hydro.w,squeeze(hydro.B(3, 3, :)),w,'linear',0)) * hydro.rho;

% Excitation
H3 = interp1(hydro.w,complex(squeeze(hydro.ex_re(3, 1, :)), ...
    squeeze(hydro.ex_im(3, 1, :))),w,'linear',0)...
    * hydro.g * hydro.rho;
H9 = interp1(hydro.w,complex(squeeze(hydro.ex_re(9, 1, :)), ...
    squeeze(hydro.ex_im(9, 1, :))),w,'linear',0)...
    * hydro.g * hydro.rho;

% Excitation Forces
E3 = H3 .* eta_fd;
E9 = H9 .* eta_fd;

% friction
% Add some friction proportional to the max radiation damping term
Bf = max(B33) * 0.1;
   
% Calculate Impedance
Z3 = B33 + Bf + 1i * ( ...
            w .* (mass1 + A33) - K3 ./ w);
Z9 = B99 + Bf + 1i * ( ...
            w .* (mass2 + A99) - K9 ./ w);
% Hydrodynamic radiation coupling between the two bodies [Falnes 1999].       
Zc = B39 + 1i * w .* A39;

% External Impedance
Z0 = Z3 + Z9 + 2*Zc;
% Intrinsic Impedance
Zi = (Z3.*Z9 - Zc.^2) ./ Z0;
% Excitation Force
F0 = (E3.*(Z9+Zc) - E9 .* (Z3 + Zc)) ./ Z0;
 


% Save all variables to struct
RM3.w = w;
RM3.dw = dw;
% Only for PS
RM3.wave_amp = waveAmp;
RM3.ph = ph;
RM3.mass1 = mass1;
RM3.mass2 = mass2;
RM3.K3 = K3;
RM3.K9 = K9;
RM3.B99 = B99;
RM3.A99 = A99;
RM3.B39 = B39;
RM3.A39 = A39;
RM3.B33 = B33;
RM3.A33 = A33;
RM3.H3 = H3;
RM3.H9 = H9;
RM3.E3 = E3;
RM3.E9 = E9;
RM3.Bf = Bf;
RM3.Z3 = Z3;
RM3.Z9 = Z9;
RM3.Zc = Zc;
RM3.Z0 = Z0;
RM3.Zi = Zi;
RM3.F0  = F0;


%% Future Functionality
% Used to check against PS method
% Relative velocity
%     Ur = F0 ./ (2 * real(Zi));
% Relative displacement
%     Sr = -1i * Ur ./ RM3.w;
% Relative force
%     Fl = conj(Zi) .* Ur;
% 
%     tkp = linspace(0, 2*pi/(mean(diff(RM3.w))), 4*(length(RM3.w)));
% 
%     exp_mat = exp(1i * RM3.w * tkp);
%     srt = real(Sr .' * exp_mat);
%     urt = real(Ur .' * exp_mat);
%     Flt = real(Fl .' * exp_mat);
end

