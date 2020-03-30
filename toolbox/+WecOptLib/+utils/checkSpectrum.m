
% Copyright 2020 Sandia National Labs
%
% This file is part of WecOptTool.
% 
%     WecOptTool is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     WecOptTool is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with WecOptTool.  If not, see <https://www.gnu.org/licenses/>.

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
ID = 'WecOptTool:invalidSpectrum:missingFields';
try
    assert(all(isfield(S,fns)),ID,msg,idx)
catch ME
    throw(ME)
end
end

function [] = checkLengths(S, idx)
msg = 'Spectrum #%i in array S.S and S.w fields are not same length';
ID = 'WecOptTool:invalidSpectrum:mismatchedLengths';
try
    assert(length(S.S) == length(S.w),ID,msg, idx)
catch ME
    throw(ME)
end
end

function [] = checkCol(S, idx)
msg = 'Spectrum #%i in array S.S and S.w fields are not column vectors';
ID = 'WecOptTool:invalidSpectrum:notColumnVectors';
try
    assert(iscolumn(S.S) && iscolumn(S.w),ID,msg, idx)
catch ME
    throw(ME)
end
end
