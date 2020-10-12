function tests = testHydrodynamics
   tests = functiontests(localfunctions);
end

function testNegativeRadDamping(testCase)
% this case is known to produce radiation values in the diagonal terms less
% than zero

    import matlab.unittest.fixtures.TemporaryFolderFixture
    
    tempFixture = testCase.applyFixture(                        ...
             TemporaryFolderFixture(                            ...
                        'PreservingOnFailure',  true,           ...
                        'WithSuffix', 'testNegativeRadDampingKnownBad'));
    
    w = [0.5:0.5:5.5];
    rf = [0, 5, 5, 0];
    rs = [0, 7.5, 7.5, 0];
    zf = [0, 0, -1.1250, -1.1250];
    zs = [-42, -42, -43, -43];
    
    % Mesh
    ntheta = 20;
    nfobj = 200;
    
    meshes = WecOptTool.mesh("AxiMesh",             ...
                             tempFixture.Folder,    ...
                             rf,                    ...
                             zf,                    ...
                             ntheta,                ...
                             nfobj,                 ...
                             1);
    meshes(2) = WecOptTool.mesh("AxiMesh",          ...
                                tempFixture.Folder, ...
                                rs,                 ...
                                zs,                 ...
                                ntheta,             ...
                                nfobj,              ...
                                2);
    
    hydro = WecOptTool.solver("NEMOH", tempFixture.Folder, meshes, w);
    
    data = struct();
    data = WecOptTool.vendor.WEC_Sim.Read_NEMOH(data,  ...
                                                hydro.runDirectory);
    
    rawBdiag = cell2mat(arrayfun(@(x) diag(data.B(:,:,x)),  ...
                                 1:size(data.B,3),          ...
                                 'UniformOutput', false));
                          
    hydroBdiag = cell2mat(arrayfun(@(x) diag(hydro.B(:,:,x)),   ...
                                   1:size(data.B,3),            ...
                                   'UniformOutput', false));
                          
    verifyTrue(testCase, any(any(rawBdiag < 0))); 
    verifyGreaterThanOrEqual(testCase, hydroBdiag, 0);
    
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
%
