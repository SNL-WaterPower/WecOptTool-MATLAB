
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

function tests = checkSpectrumTest()
   tests = functiontests(localfunctions);
end

function testCheck_missingFields(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();
    S = rmfield(S,'w');
    eID = 'WecOptTool:invalidSpectrum:missingFields';
    verifyError(testCase,@() WecOptLib.utils.checkSpectrum(S),eID)
end

function testCheck_mismatchedLengths(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();
    S.w = [];
    eID = 'WecOptTool:invalidSpectrum:mismatchedLengths';
    verifyError(testCase,@() WecOptLib.utils.checkSpectrum(S),eID)
end

function testCheck_notColumnVectors(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();
    S.w = S.w';
    eID = 'WecOptTool:invalidSpectrum:notColumnVectors';
    verifyError(testCase,@() WecOptLib.utils.checkSpectrum(S),eID)
end

function testCheck_multiSeaStates(testCase)
    S = WecOptLib.tests.data.example8Spectra();
    try 
        WecOptLib.utils.checkSpectrum(S)
    catch
        verifyFail(testCase)
    end
end
