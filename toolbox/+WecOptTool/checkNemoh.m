
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

function [hydro, ltzw_locs] = checkNemoh(hydro, plotFlag)
% Checks the results from Nemoh for the following problems and corrects the
% problems
%
% 1. diagonal radiation damping always positive
%
% Args.
%   hydro       hydro structure returned by getNemoh function
%   plotFlag    set to 1 for plots and other debugging output to command
%               window
%
% Returns
%   hydro       updated hydro structure
%   ltzw_locs   array containing locations where negative damping values
%               were found
%
% Todo
%   consider adding some check for "smoothness" for irregular frequency
%   problems that do not result in negative values
%
% -------------------------------------------------------------------------

if nargin < 2
    plotFlag = 0;
end

n = size(hydro.B, 1);
m = size(hydro.B, 2);

%% diagonal damping terms


% each row is a diagonal's FRF
Bdiag0 = cell2mat(arrayfun(@(x) diag(hydro.B(:,:,x)), 1:size(hydro.B,3),...
    'UniformOutput', false));

% array to track which terms had values less than zero
ltzw = zeros(n,1); 

for ii = 1:n
    
    % get array for the diagonal FRF
    Bdiag = squeeze(hydro.B(ii,ii,:));
    
    % mark if any elements < 0
    if any(Bdiag < 0)
        ltzw(ii) = 1;
    end
    
    % set negative elements to zero
    Bdiag(Bdiag < 0) = 0;
    
    % reassign
    hydro.B(ii,ii,:) = Bdiag;
    
end

% to check result
Bdiag1 = cell2mat(arrayfun(@(x) diag(hydro.B(:,:,x)), 1:size(hydro.B,3),...
    'UniformOutput', false));

ltzw_locs = find(ltzw ~= 0)';

% raise warning 
% if any(ltzw ~= 0)
%     ltzw_locs = find(ltzw ~= 0)';
%     warning('WecOptTool:nemohNegativeRad',...
%         ['Negative radiation values in following diagonal FRFs: ',...
%         num2str(ltzw_locs)])
% end

%% Plotting and debugging output (optional)

if plotFlag
    
    figure
    hold on
    grid on
    pb = plot(hydro.w, Bdiag0,'r','DisplayName','before');
    pa = plot(hydro.w,Bdiag1,'b','DisplayName','after');
    xlabel('Frequency [rad/s]')
    ylabel('Radiation damping')
    legend([pb(1), pa(1)])
    
    fprintf('\nBefore\n')
    fprintf('----------\n')
    disp(Bdiag0)
    fprintf('\nAfter\n')
    fprintf('---------\n')
    disp(Bdiag1)
    
end

end


