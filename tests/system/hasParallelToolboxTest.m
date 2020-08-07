function tests = hasParallelToolboxTest()
   tests = functiontests(localfunctions);
end

function testhasParallelToolbox(testCase)

    import matlab.unittest.constraints.IsSubsetOf
    
    [combined,  ...
     licensed,  ...
     installed] = WecOptTool.system.hasParallelToolbox();
 
    testCase.verifyThat(combined, IsSubsetOf(logical([0;1])));
    testCase.verifyThat(licensed, IsSubsetOf(logical([0;1])));
    testCase.verifyThat(installed, IsSubsetOf(logical([0;1])));
    
end

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
%     along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
