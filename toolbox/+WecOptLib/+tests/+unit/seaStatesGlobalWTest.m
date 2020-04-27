
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

function tests = seaStatesGlobalWTest()
   tests = functiontests(localfunctions);
end

function testCheck_stepType(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();   
    eID = 'WecOptLib:utilityFailure:stepType';
    verifyError(testCase,@() WecOptLib.utils.seaStatesGlobalW(S,'a'),eID)
end

function testCheck_stepNegativeValue(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();   
    eID = 'WecOptLib:utilityFailure:stepValue';
    verifyError(testCase,@() WecOptLib.utils.seaStatesGlobalW(S,-1.0),eID)
end

function testCheck_stepZeroValue(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();   
    eID = 'WecOptLib:utilityFailure:stepValue';
    verifyError(testCase,@() WecOptLib.utils.seaStatesGlobalW(S,0),eID)
end


function testCheck_frequecyStepValue(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();
    step=0.333;
    w = WecOptLib.utils.seaStatesGlobalW(S, step);
    verifyTrue(testCase, all(abs(diff(w)-step)<0.0001));
end

% Range check
function testCheck_frequecyMin(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();
    shiftInputFrequency = 0.17;
    S.w = S.w + shiftInputFrequency;
    SwMin = min(S.w);
    step=0.333;
    w = WecOptLib.utils.seaStatesGlobalW(S, step);
    wMin = min(w);
    
    wMinPositiveAndInStepRange=true;
    if wMin ~= SwMin
        isPositive = wMin >= 0;
        wMinInStepRange = true; 
        if isPositive
            lowerBound = SwMin - step;
            wMinInStepRange = lowerBound <= wMin & wMin < SwMin;             
        end
        wMinPositiveAndInStepRange = and(isPositive, wMinInStepRange);
    end        
    
    verifyTrue(testCase, wMinPositiveAndInStepRange);
end


function testCheck_frequecyMax(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();
    shiftInputFrequency = 0.7317;
    S.w = S.w + shiftInputFrequency;
    SwMax = max(S.w);
    step=0.333;
    w = WecOptLib.utils.seaStatesGlobalW(S, step);
    wMax = max(w);
    
    wMaxPositiveAndInStepRange=true;
    if wMax ~= SwMax
        isPositive = wMax >= 0;
        wMaxInStepRange = true; 
        if isPositive
            upperBound = SwMax + step;
            wMaxInStepRange = SwMax < wMax & wMax <= upperBound;             
        end
        wMaxPositiveAndInStepRange = and(isPositive, wMaxInStepRange);
    end        
    
    verifyTrue(testCase, wMaxPositiveAndInStepRange);
end


function testCheck_frequecyRange(testCase)
    S = WecOptLib.tests.data.exampleSpectrum();
    shiftInputFrequency = 0.7317;
    S.w = S.w + shiftInputFrequency;
    SwMin = min(S.w);
    SwMax = max(S.w);
    SwRange = SwMax - SwMin;
    step=0.333;
    w = WecOptLib.utils.seaStatesGlobalW(S, step);
    wMin = min(w);
    wMax = max(w);
    wRange = wMax - wMin;
    
    wRangePositiveAndInStepRange=true;
    if wRange ~= SwRange  
        isPositive = wRange >= 0;
        wRangeInStepRange = true; 
        if isPositive            
            upperRange = SwMax - SwMin + 2*step;
            wRangeInStepRange =   wRange <= upperRange & wRange > SwRange ;             
        end
        wRangePositiveAndInStepRange = and(isPositive, wRangeInStepRange);
    end        
    
    verifyTrue(testCase, wRangePositiveAndInStepRange);
end


function testCheck_multiSSfrequecyRange(testCase)
    S = WecOptLib.tests.data.example8Spectra();    
    step=0.333;
    w = WecOptLib.utils.seaStatesGlobalW(S, step);
    wMin = min(w);
    wMax = max(w);
    wRange = wMax - wMin;
    
    isPositive = wRange >= 0;
    wRangeInStepRange = true;                     
    if  isPositive    
        upperRange = wMax - wMin + 2*step;
        wRangeInStepRange =   wRange <= upperRange;             
    end
    wRangePositiveAndInStepRange = and(isPositive, wRangeInStepRange);
                
    verifyTrue(testCase, wRangePositiveAndInStepRange);
end
