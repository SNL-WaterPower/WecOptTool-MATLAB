
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

function [hydro,rundir] = getHydrodynamics(obj, mode, varargin)
% function [hydro] = getHydrodynamics(mode,...)
%
% Returns WEC-Sim hydro structure for RM3.
%
% Inputs
%   mode='scalar'
%       lambda  scaling factor
%   mode='paramtric'
%       r1      float radius [m]
%       r2      heave plate radius [m]
%       d1      draft of float [m]
%       d2      depth of heave plate [m]
%
% Outputs
%       hydro   BEM data saved to WEC-Sim hydro structure
%
% RG Coe 2018
% adapted from
% Penalba, Markel, Thomas Kelly, and John V. Ringwood. "Using NEMOH for
% modelling wave energy converters: A comparative study with WAMIT."
% Proceedings of the 12th European Wave and Tidal Energy Conference
% (EWTEC2017), Cork, Ireland. 2017.
%%

switch mode
    case 'scalar'
        if iscell(varargin{1})
            lambda = varargin{1}{1};
        else
            lambda = varargin{1};
        end
        
        % Get data file path
        p = mfilename('fullpath');
        [filepath, ~, ~] = fileparts(p);
        dataPath = fullfile(filepath, '..', 'RM3_BEM.mat');
        
        load(dataPath, 'hydro');
        rundir = '.';
        
        % dimensionalize w/ WEC-Sim built-in function
        hydro.rho = 1025;
        hydro.g = 9.81;
%         hydro = Normalize(hydro); % TODO - this doesn't work for our data
%         that was produced w/ WAMIT...

        
        % scale by scaling factor lambda
        hydro.Vo = hydro.Vo .* lambda^3;
        hydro.C = hydro.C .* lambda^2;
        hydro.B = hydro.B .* lambda^2.5;
        hydro.A = hydro.A .* lambda^3;
        hydro.ex = complex(hydro.ex_re,hydro.ex_im) .* lambda^2;
        hydro.ex_ma = abs(hydro.ex);
        hydro.ex_ph = angle(hydro.ex);
        hydro.ex_re = real(hydro.ex);
        hydro.ex_im = imag(hydro.ex);
        % TODO: scale rest off FRFs
        
        
    case 'parametric'
        r1 = varargin{1}(1);
        r2 = varargin{1}(2);
        d1 = varargin{1}(3);
        d2 = varargin{1}(4);
        SS = varargin{2};
        
        % Get global frequency range at 0.2Hz discrtization 
        w = WecOptLib.utils.seaStatesGlobalW(SS, 0.2);
               
        if w(1) == 0
            w = w(2:end);
        end        
        [hydro,rundir] = RM3_parametric(w,r1,r2,d1,d2);
    case 'existing'
        rundir = varargin{1};
        hydro = struct();
        hydro = WecOptLib.vendor.WEC_Sim.Read_NEMOH(hydro, rundir);
        hydro.rundir = rundir;
    otherwise
        errmsg = ['Invalid argument for RM3_getNemoh.  Must be either', ...
                 ' "parametric", "scalar", or "existing".  Perhaps a typo was made...'];
        error(errmsg);
end

% hydro = Normalize(hydro);

end

function [hydro,rundir] = RM3_parametric(w,r1,r2,d1,d2)

% Store NEMOH output in fixed user-centric location
nemohPath = WecOptLib.utils.getSrcRootPath();
subdirectory = fullfile(nemohPath, '~nemoh_runs');
procid = 0;

if WecOptLib.utils.hasParallelToolbox()
    
    worker = getCurrentWorker;

    if(~isa(worker, 'double'))
        procid=worker.ProcessId;
    end
    
end

rundir = fullfile(subdirectory,...
    [datestr(now,'yymmdd_HHMMssFFF'),'_',num2str(procid)]);

%% Float

rf = [0 r1 r1 0];
zf = [0 0 -d1 -d1];

%% Heave plate

thk = 1;
rs = [0 r2 r2 0];
zs = [-d2 -d2 -d2-thk -d2-thk];

%% Combine

% figure
% hold on
% plot(rf,zf,'.-')
% plot(rs,zs,'.-')
% xlim([0, Inf])
% ylim([-Inf, 0])
% grid on
% return

r = {rf, rs};
z = {zf, zs};

%% Solve

[hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);
hydro.rundir = rundir;

end
