function [pow, etc] = RM3_getPow(S,                 ...
                                 controlType,       ...
                                 geomMode,          ...
                                 geomParams,        ...
                                 controlParams)
% pow = RM3_getPow(S, controlType, geomMode, ...)
%
% Top-level evaluation function for RM3 device.
%
% Inputs
%       S               wave spectra structure, with fields:
%           S.S         spectral energy distribution [m^2 s/rad]
%           S.w         frequency [rad/s]
%           S.ph        phasing
%           S.mu        weighting factor
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
%       geomParams      contains parameters for the geometric mode
%       controlParams   if using the 'PS' control type, optional arguments for
%                       deltaZmax and deltaFmax
%                           Note: to use the optional arguments, both must
%                           be provided, otherwise the program will use
%                           default values of
%                               deltaZmax = 10
%                               deltaFmax = 1e9
% Outputs
%       pow             power weighted by weighting factors
%       etc             structure with two items, containing pow and the
%                       hydro struct from Nemoh
%
% Examples:
% 1) Using scalar input with CC control and scaling factor 1:
%
% S = bretschneider([],[8,10],0);
% [pow, etc] = RM3_getPow(S, 'CC', 'scalar', 1);
%
%
% 2) Using 'PS' control with optional deltaZmax and deltaFmax specified
%
% S = bretschneider([],[8,10],0);
%
% r1 = 10;       % radius of float
% r2 = 15;       % radius of sink
% d1 = 2;        % float depth
% d2 = 42;       % sink depth
%
% deltaZmax = 15;
% deltaFmax = 1e7;
%
% [pow, etc] = RM3_getPow(S, 'PS', 'parametric', [r1,r2,d1,d2], deltaZmax, deltaFmax);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check inputs
if ~isfield(S,'mu')
    for ind_ss = 1:length(S)
        S(ind_ss).mu = 1;
    end
    if length(S) > 1
        warning('No weighting field mu in wave spectra structure S, setting to 1')
    end
end

% get the hydrodynamic FRFs
[hydro,rundir] = WecOptLib.volatile.RM3_getNemoh(geomMode, geomParams);

% find WEC performance
maxVals = [];

if strcmp(controlType, 'PS')
    if nargin == 5
        maxVals = controlParams;
    end
end

% Iterate over Sea-States
for ind_ss = 1:length(S) % TODO - consider parfor?
    pow_ss(ind_ss) = WecOptLib.volatile.RM3_eval(S(ind_ss), hydro, controlType, maxVals);
end

% assemble output
mus = [S(:).mu];
pow = dot(pow_ss(:), mus(:)) / sum([S(:).mu]);

etc.pow = pow_ss;
etc.hydro = hydro;
etc.rundir = rundir;

end


