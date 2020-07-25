function tests = mustBeEqualLengthTest()
   tests = functiontests(localfunctions);
end

function test_mustBeEqualLength_scalar(testCase)
    x=1.0;
    y=2.0;
    verifyWarningFree(testCase, ...
                      @() WecOptLib.validation.mustBeEqualLength(x,y))
end

function test_mustBeEqualLength_array(testCase)
    x=ones(1,5);
    y=zeros(1,5);
    verifyWarningFree(testCase, ...
                      @() WecOptLib.validation.mustBeEqualLength(x,y))
end

function test_mustBeEqualLength_mixed(testCase)
    x = WecOptLib.tests.data.example8Spectra();
    y = zeros(length(x),1);
    verifyWarningFree(testCase, ...
                      @() WecOptLib.validation.mustBeEqualLength(x,y))
end

function test_mustBeEqualLength_error(testCase)
    x=1.0;
    y=[2, 3];
    eID = 'WecOptLib:Validation:NotEqualLength';
    verifyError(testCase,                                           ...
                @() WecOptLib.validation.mustBeEqualLength(x,y),    ...
                eID)
end

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
