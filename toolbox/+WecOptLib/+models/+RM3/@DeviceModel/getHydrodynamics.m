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
        dataPath = [filepath filesep '..' filesep 'RM3_BEM.mat'];
        
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
        [hydro,rundir] = RM3_parametric(r1,r2,d1,d2);
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

function [hydro,rundir] = RM3_parametric(r1,r2,d1,d2)

w = linspace(0.2,2,10); % TODO: set this based on wave spectrum

%% Store NEMOH output in fixed user-centric location
nemohPath = WecOptLib.utils.getSrcRootPath();
subdirectory = fullfile(nemohPath, '~nemoh_runs');

worker = getCurrentWorker;
procid=0;

if(~isa(worker, 'double'))
    procid=worker.ProcessId;
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
