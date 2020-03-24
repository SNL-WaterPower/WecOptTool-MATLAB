function [] = checkSpectrum(S)
% checkSprectrum(S)
%
% Checks whether the input S is a valid spectrum structure (following
% WAFO).
%
% Inputs
%   S           spectrum structure (can be arrary) in the style of WAFO
%               with the fields:
%       S.w     column vector of frequencies in [rad/s]
%       S.S     column vector of spectral density in [m^2 rad/ s]
%
% Outputs
%   (none)      (will throw error if not valid)
%
%
% Example
%   Hm0 = 5;
%   Tp = 8;
%   S = bretschneider([],[Hm0,Tp]);
%   WecOptLib.utils.checkSpectrum(S)
%
% -------------------------------------------------------------------------


inds = 1:length(S);

try
    arrayfun(@(Spect,idx) checkFields(Spect, idx), S, inds);
    arrayfun(@(Spect,idx) checkLengths(Spect, idx), S, inds);
    arrayfun(@(Spect,idx) checkCol(Spect, idx), S, inds);
catch MEs
    throw(MEs)
end

end

function [] = checkFields(S, idx)
fns = {'S','w'};
msg = 'Spectrum #%i in array does not contain required S.S and S.w fields';
try
    assert(all(isfield(S,fns)),msg,idx)
catch ME
    throw(ME)
end
end

function [] = checkLengths(S, idx)
msg = 'Spectrum #%i in array S.S and S.w fields are not same length';
try
    assert(length(S.S) == length(S.w),msg, idx)
catch ME
    throw(ME)
end
end

function [] = checkCol(S, idx)
msg = 'Spectrum #%i in array S.S and S.w fields are not column vectors';
try
    assert(iscolumn(S.S) && iscolumn(S.w),msg, idx)
catch ME
    throw(ME)
end
end
