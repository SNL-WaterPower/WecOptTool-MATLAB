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
