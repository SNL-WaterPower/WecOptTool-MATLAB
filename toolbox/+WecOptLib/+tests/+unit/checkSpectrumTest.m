function tests = checkSpectrumTest()
   tests = functiontests(localfunctions);
end

function testCheck_missingFields(testCase)
    S = bretschneider([],[4,5]);
    S = rmfield(S,'w');
    eID = 'WecOptTool:invalidSpectrum:missingFields';
    verifyError(testCase,@() WecOptLib.utils.checkSpectrum(S),eID)
end

function testCheck_mismatchedLengths(testCase)
    S = bretschneider([],[4,5]);
    S.w = [];
    eID = 'WecOptTool:invalidSpectrum:mismatchedLengths';
    verifyError(testCase,@() WecOptLib.utils.checkSpectrum(S),eID)
end

function testCheck_notColumnVectors(testCase)
    S = bretschneider([],[4,5]);
    S.w = S.w';
    eID = 'WecOptTool:invalidSpectrum:notColumnVectors';
    verifyError(testCase,@() WecOptLib.utils.checkSpectrum(S),eID)
end

function testCheck_multiSeaStates(testCase)
    S = arrayfun(@(x) bretschneider([],[4,x]), 4:0.1:5);
    try 
        WecOptLib.utils.checkSpectrum(S)
    catch
        verifyFail(testCase)
    end
end
