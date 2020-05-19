
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

function tests = errorCheckTests()
   tests = functiontests(localfunctions);
end


function testCheck_successEqualLengths(testCase)
    x=1.0;
    y=2.0;
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertEqualLength(x,y))
end

function testCheck_successEqualLengthsArray(testCase)
    x=ones(1,5);
    y=zeros(1,5);
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertEqualLength(x,y))
end

function testCheck_successEqualLengthsStructs(testCase)
    x= WecOptLib.tests.data.example8Spectra();
    y=zeros(length(x),1);
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertEqualLength(x,y))
end

function testCheck_errorUnequalLengths(testCase)
    x=1.0;
    y=[2, 3];
    eID = 'WecOptLib:errorCheckFailure:unequalLengths';
    verifyError(testCase,@() WecOptLib.errorCheck.assertEqualLength(x,y),eID)
end

function testCheck_successGreaterThan(testCase)
    x=3.0;
    y=2.0;
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertGreaterThan(x,y))
end

function testCheck_successGreaterThanArrayX(testCase)
    x=linspace(2.1,5,3);
    y=2.0;
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertGreaterThan(x,y))
end

function testCheck_successGreaterThanArrayY(testCase)
    x=6;
    y=linspace(2.1,5,3);
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertGreaterThan(x,y))
end

function testCheck_errorNotGreaterThan(testCase)
    x=2.0;
    y=2.0;
    eID = 'WecOptLib:errorCheckFailure:greaterThan';
    verifyError(testCase,@() WecOptLib.errorCheck.assertGreaterThan(x,y),eID)
end

function testCheck_errorNotGreaterThanArrayX(testCase)
    x=linspace(0,5,3);
    y=6;
    eID = 'WecOptLib:errorCheckFailure:greaterThan';
    verifyError(testCase,@() WecOptLib.errorCheck.assertGreaterThan(x,y),eID)
end

function testCheck_errorNotGreaterThanArrayY(testCase)
    x=2;
    y=linspace(2,5,3);
    eID = 'WecOptLib:errorCheckFailure:greaterThan';
    verifyError(testCase,@() WecOptLib.errorCheck.assertGreaterThan(x,y),eID)
end

function testCheck_successGreaterThanOrEq(testCase)
    x=2;
    y=2;
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertGreaterThanOrEqual(x,y))
end

function testCheck_successGreaterThanOrEqArrayX(testCase)
    x=linspace(2,5,3);
    y=2;
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertGreaterThanOrEqual(x,y))
end

function testCheck_successGreaterThanOrEqArrayY(testCase)
    x=5;
    y=linspace(2,5,3);
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertGreaterThanOrEqual(x,y))
end

function testCheck_errorGreaterThanOrEq(testCase)
    x=1;
    y=2;
    eID = 'WecOptLib:errorCheckFailure:greaterThanOrEqual';
    verifyError(testCase,@() WecOptLib.errorCheck.assertGreaterThanOrEqual(x,y),eID)
end

function testCheck_errorGreaterThanOrEqArrayX(testCase)
    x=linspace(1,3,3);
    y=2;
    eID = 'WecOptLib:errorCheckFailure:greaterThanOrEqual';
    verifyError(testCase,@() WecOptLib.errorCheck.assertGreaterThanOrEqual(x,y),eID)
end

function testCheck_errorGreaterThanOrEqArrayY(testCase)
    x=2;
    y=linspace(1,3,3);
    eID = 'WecOptLib:errorCheckFailure:greaterThanOrEqual';
    verifyError(testCase,@() WecOptLib.errorCheck.assertGreaterThanOrEqual(x,y),eID)
end

function testCheck_successIsField(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();
    fld='w';
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertIsField(S,fld))
end

function testCheck_errorIsField(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();
    fld='aklsgsl';
    eID = 'WecOptLib:errorCheckFailure:fieldNotFound';
    verifyError(testCase,@() WecOptLib.errorCheck.assertIsField(S,fld),eID)
end

function testCheck_successLengthOneOrLengthSSOne(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();
    x=5.0;
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertLengthOneOrLengthSS(x,S))
end

function testCheck_successLengthOneOrLengthSSOneArrayS(testCase)
    S = WecOptLib.tests.data.example8Spectra();
    x=ones(1,1);    
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertLengthOneOrLengthSS(x,S))
end

function testCheck_successLengthOneOrLengthSSOneArrayX(testCase)
    S = WecOptLib.tests.data.example8Spectra();
    x=ones(1,length(S));    
    verifyWarningFree(testCase,@() WecOptLib.errorCheck.assertLengthOneOrLengthSS(x,S))
end

function testCheck_errorLengthOneOrLengthSSOne(testCase)
    S = WecOptLib.tests.data.example8Spectra();
    x=ones(1,length(S)-1);
    eID = 'WecOptLib:errorCheckFailure:incorrectLength';
    verifyError(testCase,@() WecOptLib.errorCheck.assertLengthOneOrLengthSS(x,S),eID)
end
