function tests = getNemohTest
   tests = functiontests(localfunctions);
end

function testNoExtraFigures(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testNoExtraFigures'));

    h =  findobj('type','figure');
    nExpected = length(h);
    
    w = 0.1;
    r=[0 1 1 0]; 
    z=[.5 .5 -.5 -.5];
    
    ntheta = 20;
    nfobj = 200;
    zG = 0;

    meshes = WecOptTool.mesh("AxiMesh",             ...
                             tempFixture.Folder,    ...
                             r,                     ...
                             z,                     ...
                             ntheta,                ...
                             nfobj,                 ...
                             1);

    WecOptTool.solver("NEMOH",             ...
                      tempFixture.Folder,  ...
                      meshes,              ...
                      w);
    
    h =  findobj('type','figure');
    nActual = length(h);
    
    verifyEqual(testCase, nActual, nExpected)

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
