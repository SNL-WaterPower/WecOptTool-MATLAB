% ShapeStudy
%
% This file is part of WecOptTool.
%
%     WecOptTool is free software: you can redistribute it and/or modify it
%     under the terms of the GNU General Public License as published by the
%     Free Software Foundation, either version 3 of the License, or (at
%     your option) any later version.
%
%     WecOptTool is distributed in the hope that it will be useful, but
%     WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with WecOptTool.  If not, see <https://www.gnu.org/licenses/>.


simulate = true; 
%simulate = false;
%% define sea state of interest
dw = 0.3142;
nf = 50;
w = dw * (1:nf)';
S = jonswap(w,[0.25, 3.5, 1]);
SS = WecOptTool.SeaState(S);

% Amp = 0.125/2;
% wp = w(6);
% fp = wp/(2*pi);
% Tp = 1/fp; 
% SS = WecOptTool.SeaState.regularWave(w,[Amp,Tp]);

%% set up device types

controlType{1} = 'CC';
controlType{2} = 'P';
controlType{3} = 'PS';
zmax = 0.6;
fmax = 1e10;

folder = WecOptTool.AutoFolder();

%% Create Devices & Plot Geometries

AR = [ 0.1, 0.125, 0.15,  0.2, 0.3, 0.4, 0.5, 0.7, 1.0, 2, 3, 6, 10];
%AR = [0.1:0.5:10];
volume=0.875;
heights = (volume./(pi * AR.^2)).^(1/3);
radii = AR.*heights;

%% Running hydrodynamics
N = length(AR);
if simulate
    [deviceHydro, mesh] = designDevice('parametric', folder.path, ...
                                       radii(1), heights(1), w);
    % Tune mass to desired natural frequency
    wdes = 0.625*2*pi;  
    dynModel = getDynamicsModel(deviceHydro, ...
                                SS,       ...
                                'linear', ...
                                wdes);                                    
    perform = simulateDevice(dynModel(1), controlType{1},     ...
                             'interpMethod','nearest',    ...
                             'Zmax',zmax, 'Fmax',fmax);       
                         
    deviceHydro = repmat(deviceHydro, length(AR), 1 );
    meshes = repmat(mesh, length(AR), 1 );
    dynModel = repmat(dynModel, length(AR), 1 );
    perform  = repmat(perform, length(AR), 1 );
    
    for i = 2:length(AR)    
        radius = radii(i);
        height = heights(i);
        [deviceHydro(i), meshes(i)] = designDevice('parametric', ...
                                          folder.path, radius, height, w);    

        %% Tune Device Mass to a Natural Frequency
        
        dynModel(i) = getDynamicsModel(deviceHydro(i), ...
                                       SS,       ...
                                       'linear', ...
                                       wdes);       
        perform(i) = simulateDevice(dynModel(i), controlType{1}, ...
                                    'interpMethod','nearest',    ...
                                    'Zmax',zmax, 'Fmax',fmax);
    end
    
% Plot the parametric meshes
    plotMesh=false;
    if plotMesh == true
    %WecOptTool.plot.plotMesh(mesh)
    for ii = 1:length(AR)
        WecOptTool.plot.plotMesh(meshes(ii))
    end    
    end
    

end

%% Plot mass ratio

figure('position',[0 0 2e3 1e3]*0.25)
hold on
grid on
bar(AR,[dynModel.mass] ./( [deviceHydro.Vo] .* [deviceHydro.rho] ))
xlabel('Aspect ratio')
ylabel('Mass ratio, m^\prime/m')


%% Plot hydro
close all
clear ax

[xp,yp] = meshgrid(w,AR);

fh(1) = figure('name','Radiation added mass (A)');
ax(1) = gca;
hold on
grid on
A = [dynModel.A]-[dynModel.Ainf];
surf(xp',yp',(A)./max(max(A)));
rotate3d on
view([20, 12])


fh(2) = figure('name','Radiation wave damping (B)');
ax(2) = gca;
hold on
grid on
surf(xp',yp',[dynModel.B]./max(max([dynModel.B])))
rotate3d on

view([20, 12])


fh(3) = figure('name','Power');
ax(3) = gca;
hold on
grid on
% surf(xp',yp',abs(Ex)./max(max(abs(Ex))))
Popt = abs([dynModel.Hex].*SS.S).^2./(8*real([dynModel.Zi]));
Popt(~isfinite(Popt)) = 0;
%surf(xp',yp',Popt./max(max(Popt)))
surf(xp',yp',real([perform.pow]))
rotate3d on
view([20, 12])


fh(4) = figure('name','Zopt/max(Zopt)');
ax(4) = gca;
hold on
grid on
zopt = abs([dynModel.Hex].*SS.S./(2*real([dynModel.Zi]).*(1i*w*ones(1,N))));
zopt(~isfinite(zopt)) = 0;
surf(xp',yp',zopt./max(max(zopt)))
rotate3d on
view([20, 12])


fh(5) = figure('name','Real(Zi)');
ax(5) = gca;
hold on
grid on
%surf(xp',yp',real([dynModel.Zi])/max(max(abs(real([dynModel.Zi])))))
surf(xp',yp',real([perform.Zpto]) ./ max(max(abs((real([perform.Zpto]))))))
rotate3d on
view([20, 12])

fh(6) = figure('name','Im(Zi)');
ax(6) = gca;
hold on
grid on
%surf(xp',yp',imag([dynModel.Zi])/max(max(abs(imag([dynModel.Zi])))))
surf(xp',yp',imag([perform.Zpto]) ./ max(max(abs((imag([perform.Zpto]))))))
surf(xp',yp',zeros(size(xp')),'FaceAlpha',0.25,'EdgeColor','none',...
     'FaceColor','blue')
rotate3d on


Link = linkprop(ax, ...
       {'CameraUpVector', 'CameraPosition', 'CameraTarget'});
setappdata(gcf, 'StoreTheLink', Link);
view([20, 12])


for ii = 1:6
    xlabel(ax(ii),'Freq. [rad/s]')
    ylabel(ax(ii),'Aspect ratio [ ]')
    zlabel(ax(ii),fh(ii).Name)
end

%% Simulate Device Performance

% if simulate
% clear r
% %r{length(controlType), length(AR)} = {};
% for ii = 1:length(controlType)   
%     for jj = 1:length(AR)       
%         rng(3) % run same wave phasing for each case
%         r(jj,ii) = simulateDevice(deviceHydro(jj), SS, controlType{ii}, ...
%                                   'interpMethod','nearest','Zmax',zmax, ...
%                                   'Fmax',fmax, 'mass', mass(jj));
%         r(jj,ii).name = [controlType{ii}, '_', num2str(AR(jj))];
%     end
% end
% end



% %% set up optimization problems
% 
% x0 = 2;
% A = [];
% B = [];
% Aeq = [];
% Beq = [];
% LB = min(AR);
% UB = max(AR);
% NONLCON = [];
% opts = optimset('fminbnd');
% opts.UseParallel = true;
% opts.Display = 'iter';
% opts.PlotFcn = {@optimplotx,@optimplotfval};
% 
% %% run optimization solver (for each control type)
% 
% if simulate
%     clear fval x_opt exitflag output optSimres results
%     results(length(controlType))= struct();
%     for ii = 1:length(controlType)
%         disp("Simulation " + (ii) + " of " + length(controlType))    
%         [xOpt, fVal, exitFlag, output] = ...
%             fminbnd(@(x) myWaveBotObjFun(x,w,SS,controlType{ii},zmax,fmax,...
%             folder.path),LB,UB,opts);
%         [~, optSimRes, optHydro] = ...
%             myWaveBotObjFun(xOpt,w,SS,controlType{ii},zmax,fmax,folder.path);
% 
%         results(ii).xOpt = xOpt;
%         results(ii).fVal = fVal;
%         results(ii).exitFlag = exitFlag;
%         results(ii).output = output;
% 
%         results(ii).optSimRes = optSimRes;
%         results(ii).optHydro = optHydro;
% 
%     end
% end
% 
% % %% Plot optimized geometry relative to parametric geo
% % 
% % fig = figure('name','Shape Study');
% % %fig.Position = fig.Position .*[1,1,1.5,0.75];
% % hold on
% % grid on
% % ax = gca;
% % 
% % mkrs = {'^','o','s'};
% % % Plot Optimal Solutions
% % for ii = 1:length(controlType)
% %     ARopt= results(ii).xOpt;
% %     height = (volume./(pi * ARopt.^2)).^(1/3);
% %     radius = ARopt.*height;
% % 
% %     xCoords =  [0, radius, radius, 0];
% %     yCoords = [0.2, 0.2, -height, -height]; 
% %     p(ii) = plot(ax, xCoords, yCoords, 'Marker', mkrs{ii},...
% %                             'LineWidth',2,'MarkerSize',10);
% % end
% % 
% % for ii = 1:length(AR)
% %     radius = radii(ii);
% %     height = heights(ii);
% %     xCoords =  [0, radius, radius, 0];
% %     yCoords = [0.2, 0.2, -height, -height];
% %     p(length(controlType)+ii) = plot(ax,xCoords, yCoords, 'bo-','DisplayName',num2str(ii));
% % end
% % 
% % 
% % 
% % l1 = legend('CC','P','PS', 'Parametric geometries');
% % set(l1,'location','southeast')
% % xlabel('$r$ [m]','interpreter','latex')
% % ylabel('$z$ [m]','interpreter','latex')
% % %axis equal
% % %ylim([-0.6, 0])
% % %xlim([0, rmax])
% % %% Plot Paramteric & Optimization Results
% % 
% % fig = figure('Name','Shape_study');
% % mys = {'log','linear','log','log'};
% % for ii = 1:4
% %     ax(ii) = subplot(4,1,ii);
% %     set(ax(ii),'yscale',mys{ii})
% %     grid on
% %     hold on
% % end
% % 
% % % Plot the Parametric Results
% % for ii = 1:size(r,2)
% %     SMRY = summary(r(:,ii));
% %     pow = abs(SMRY.AvgPow);
% %     vol = arrayfun(@(x) deviceHydro(x).Vo, 1:length(AR))';
% %     
% %     massRatio = arrayfun(@(x) mass(x)/(deviceHydro(x).Vo * rho),...
% %                            1:length(AR))';  
% %     pos = SMRY.MaxPos;
% %     obfn = pow ./ (0.88 + radii').^3;
% %     
% %     semilogy(ax(1), AR, pow, 'Marker', mkrs{ii},'LineWidth',1.5)
% %     plot(    ax(2), AR, massRatio,'Marker', mkrs{ii},'LineWidth',1.5)
% %     semilogy(ax(3), AR, pos, 'Marker', mkrs{ii},'LineWidth',1.5)
% %     semilogy(ax(4), AR, obfn,'Marker', mkrs{ii},'LineWidth',1.5)
% % end
% % 
% % for jj = 1:length(ax)
% %     set(ax(jj),'ColorOrderIndex',1)
% % end
% % 
% % % Plot Optimal Solutions
% % for ii = 1:length(controlType)
% %     xOpt= results(ii).xOpt;
% %     
% %     SMRY = summary(results(ii).optSimRes);
% %     pow = abs(SMRY.AvgPow);
% %     massRatio = results(ii).optSimRes.mass/(results(ii).optHydro.Vo*rho);
% %     pos = SMRY.MaxPos;
% %     obfn = -1*results(ii).fVal;
% %      
% %     stem(ax(1), xOpt, pow, 'Marker', mkrs{ii},...
% %         'LineWidth',2,'MarkerSize',10)
% %     stem(ax(2), xOpt, massRatio, 'Marker', mkrs{ii},...
% %         'LineWidth',2,'MarkerSize',10)
% %     stem(ax(3), xOpt, pos, 'Marker', mkrs{ii},...
% %         'LineWidth',2,'MarkerSize',10)
% %     stem(ax(4), xOpt, obfn, 'Marker', mkrs{ii},...
% %         'LineWidth',2,'MarkerSize',10)
% % end
% % 
% % fs = 15;
% % ylabel(ax(1),'Avg. pow [W]','interpreter','latex','FontSize',fs)
% % ylabel(ax(2),'Mass ratio, m$^\prime$/m','interpreter','latex','FontSize',fs)
% % ylabel(ax(3),'Pos. amp. [m]','interpreter','latex','FontSize',fs)
% % ylabel(ax(4),'$-1\cdot{}$Obj. fun. [W/m$^3$]','interpreter','latex','FontSize',fs)
% % 
% % set(ax(1:3),'XTickLabel',[])
% % 
% % l1 = legend(ax(1),'CC','P','PS');
% % set(l1,'location','southeast')
% % xlabel('Aspect Ratio, radius:height','interpreter','latex','FontSize',fs)
% % linkaxes(ax,'x')
% % %xlim([0.25, max(AR)])
% % 
% % annotation(gcf,'textarrow',[0.808928571428571 0.728571428571429],...
% %         [0.49047619047619 0.434920634920635],'String','$z^{\textrm{{max}}}$',...
% %         'Interpreter','latex',...
% %         'FontSize',18);
% % h = plot(ax(3),[0,1e10],zmax * ones(2,1),'k--');
% % uistack(h,'bottom');
% 
% 
% 
% 
% %% objective function
% 
% function [fval, simRes, deviceHydro] = myWaveBotObjFun(x,w,SS,controlType,zmax,fmax,folderPath)        
%     
%     % create device and simulate performance the parametric input is 
%     % [r1, r2, d1, d2] (all positive); here we specify only AR
%     height = (0.875./(pi * x^2)).^(1/3);
%     radius = x*height;
%     
%     deviceHydro = designDevice('parametric', folderPath, ...
%                                radius, height, w);
%     % Tune the mass to wDesired                       
%     wdes = 0.625*2*pi;    
%     m = deviceHydro.Vo * deviceHydro.rho;
%       
%     A = squeeze(deviceHydro.A(3,3,:))*deviceHydro.rho;
%     B = squeeze(deviceHydro.B(3,3,:)).*w'*deviceHydro.rho;
%     C = deviceHydro.C(3,3)*deviceHydro.rho*deviceHydro.g;
% 
%     fun = @(m) tune_wdes(wdes,m,C,w,A(:));
%     mtune = fminsearch(fun,m);
%                                
%     % Simulate the device                       
%     simRes = simulateDevice(deviceHydro,               ...
%                             SS,                        ...
%                             controlType,           ...
%                             'interpMethod','nearest',  ...
%                             'Zmax',zmax,               ...
%                             'Fmax',fmax,               ...
%                             'mass', mtune);
%     if strcmp(controlType,'PS')
%         pow =simRes.pow(:,1);
%     else
%         pow = simRes.pow;
%     end
%     
%     % objective function value
%     p_bar = sum(real(pow));             % average power
%     fval = 1 * p_bar ./ (0.88 + radius).^3;  % r1 = 0.88 is as-built WaveBot
% end
% 
% 
% 
