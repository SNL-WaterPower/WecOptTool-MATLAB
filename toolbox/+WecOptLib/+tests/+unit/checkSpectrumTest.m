
% Copyright 2020 National Technology & Engineering Solutions of Sandia, 
% LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
% U.S. Government retains certain rights in this software.
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

function testCheck_Positive(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();
    S.w(1) = -1.0;
    eID = 'WecOptTool:invalidSpectrum:negativeFrequencies';
    verifyError(testCase,@() WecOptLib.utils.checkSpectrum(S),eID)
end

function testCheck_missingWeights(testCase)
    S = WecOptLib.tests.data.example8Spectra();
    S = rmfield(S,'mu');
    wID = 'WaveSpectra:NoWeighting';
    verifyWarning(testCase,@() WecOptLib.utils.checkSpectrum(S),wID)
end

function testCheck_WeightingsInconsistent(testCase)
    S = WecOptLib.tests.data.example8Spectra();
    S(1).mu = [];
    eID = 'WecOptTool:invalidSpectrum:invalidWeightings';
    verifyError(testCase,@() WecOptLib.utils.checkSpectrum(S),eID)
end
