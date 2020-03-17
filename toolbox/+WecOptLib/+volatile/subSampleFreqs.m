function [new_w, new_S] = subSampleFreqs(S, npoints)
%subSampleFreq - subsamples sea state and interpolates to three harmonics
%    gets a subsampling of a given seastate by linear interpolation
%    Inputs:
%        S = seastate.  must have S.S and S.w
%        npoints = number of points to subsample
%    Outputs:
%        newS = new density values
%        neww = new frequency values

if(nargin < 2)
    npoints = 120;
end
ind_sp = find(S.S > 0.01 * max(S.S),1,'last');

new_w = linspace(S.w(1), S.w(ind_sp) * 3, npoints)';
new_S = interp1(S.w, S.S, new_w,'linear',0);

end