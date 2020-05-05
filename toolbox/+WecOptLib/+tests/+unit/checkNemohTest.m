
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
%
% Notes: 
%
% tests that check Nemoh can catch cases with problematic output from Nemoh

function tests = checkNemohTest
   tests = functiontests(localfunctions);
end

function testNegativeRadDampingKnownGood(testCase)
% this case is known to NOT have any negative radiation damping values
% along the diagonals, hence we check that checkNemoh.m does not through a
% false postive

    import matlab.unittest.fixtures.TemporaryFolderFixture
    
    tempFixture = testCase.applyFixture(                            ...
         TemporaryFolderFixture(                                    ...
                        'PreservingOnFailure',  true,               ...
                        'WithSuffix', 'testNegativeRadDampingKnownGood'));
    
    w = 0.1;
    r = [0, 1, 1, 0]; 
    z = [0.5, 0.5, -0.5, -0.5];
    
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,tempFixture.Folder);
    [~, ltzw_locs] = WecOptLib.nemoh.checkNemoh(hydro, 0);
    
    verifyEmpty(testCase, ltzw_locs,                                    ...
        ['Case known to have no negative diagonal radiation values'     ...
        'flagged for negative values'])
end

function testNegativeRadDampingKnownBad(testCase)
% this case is known to produce radiation values in the diagonal terms less
% than zero, hence we test that checkNemoh.m performs its job

    import matlab.unittest.fixtures.TemporaryFolderFixture
    
    tempFixture = testCase.applyFixture(                        ...
             TemporaryFolderFixture(                            ...
                        'PreservingOnFailure',  true,           ...
                        'WithSuffix', 'testNegativeRadDampingKnownBad'));
    
    w = [0.5:0.5:5.5];
    r{1} = [0, 5, 5, 0];
    r{2} = [0, 7.5, 7.5, 0];
    z{1} = [0, 0, -1.1250, -1.1250];
    z{2} = [-42, -42, -43, -43];
    
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,tempFixture.Folder);
    [hydro, ltzw_locs] = WecOptLib.nemoh.checkNemoh(hydro, 0);
    
    expRes = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    verifyEqual(testCase, ltzw_locs, expRes,...
        ['Case known to have negative diagonal radiation values'...
        'not correctly flagged for negative values'])
    
    Bdiag = cell2mat(arrayfun(@(x) diag(hydro.B(:,:,x)),        ...
                              1:size(hydro.B,3),                ...
                              'UniformOutput', false));
    verifyGreaterThanOrEqual(testCase,Bdiag,0,                  ...
        'Negative diagonal radiation values not set to zero');
    
end
