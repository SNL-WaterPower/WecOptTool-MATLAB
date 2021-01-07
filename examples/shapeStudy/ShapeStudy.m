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
constant='Spect';
%constant='Force';
%constant='Power';

%% define sea state of interest
dw = 0.3142;
nf = 50;
%nf = 30;
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

%AR = [ 0.1, 0.125, 0.15,  0.2, 0.3, 0.4, 0.5, 0.7, 1.0, 2, 3, 6, 10];
AR = [0.3, 0.4, 0.5, 0.7, 1.0, 2, 3, 6, 10];
%AR = [ 5, 10, 50, 100, 200];
%AR = [0.1:0.5:10];
volume=0.875;
heights = (volume./(pi * AR.^2)).^(1/3);
radii = AR.*heights;

fig = figure('name','Shape Study');
%fig.Position = fig.Position .*[1,1,1.5,0.75];
hold on
grid on
set(gca, 'fontsize',16);
for ii = 1:length(AR)
    radius = radii(ii);
    height = heights(ii);
    xCoords =  [0, radius, radius, 0];
    yCoords = [0.2, 0.2, -height, -height];
    ax = gca;
    p(ii) = plot(ax, xCoords, yCoords, 'bo-','DisplayName',num2str(ii));    
end
axis equal
% xlabel('Radius [m]')
% ylabel('Height [m]')
% ylim([-inf 0])
% x = [0.7 0.5];
% y = [0.2 0.2];
% annotation('textarrow',x,y,'String','Low AR')
% x = [0.85 0.85];
% y = [0.4 0.7];
% annotation('textarrow',x,y,'String','High AR')
% saveas(fig, 'plots/aspectRatios.pdf')

%% Running hydrodynamics

N = length(AR);
% Determine the value of the constant force
iAR = N; 
remaingARIndicies = setdiff(find(AR), iAR);

[deviceHydro, mesh] = designDevice('parametric', folder.path, ...
                                   radii(iAR), heights(iAR), w);
% Tune mass to desired natural frequency
wdes = 0.625*2*pi;  
dynModel = getDynamicsModel(deviceHydro, ...
                            SS,          ...
                            'linear',    ...
                            wdes); 
%mean(dynModel.F0)
% Constant Force? 
if all(constant == 'Force')
    Fconstant = ones(length(w),1) * mean(dynModel.F0);
    dynModel.F0 = Fconstant;
elseif all(constant == 'Power')
    Fconstant = sqrt(8*real([dynModel.Zi]));
    dynModel.F0 = Fconstant(:,1);
end
if ~all(constant == 'Spect')
    dynModel.eta_fd = dynModel.F0 ./ dynModel.Hex;
end
perform = simulateDevice(dynModel(1), controlType{1},     ...
                         'interpMethod','nearest',    ...
                         'Zmax',zmax, 'Fmax',fmax);       

deviceHydro = repmat(deviceHydro, N, 1 );
meshes = repmat(mesh, N, 1 );
dynModel = repmat(dynModel, N, 1 );
perform  = repmat(perform, N, 1 );

for i = remaingARIndicies
    radius = radii(i);
    height = heights(i);
    [deviceHydro(i), meshes(i)] = designDevice('parametric', ...
                                      folder.path, radius, height, w);    

    %% Tune Device Mass to a Natural Frequency
    dynModel(i) = getDynamicsModel(deviceHydro(i), ...
                                   SS,       ...
                                   'linear', ...
                                   wdes);      
                           
    if all(constant == 'Force')
        Fconstant = ones(length(w),1) * mean(dynModel(iAR).F0);%Global Const
        %Fconstant = ones(length(w),1) * mean(dynModel(i).F0); % AR const
        dynModel(i).F0 = Fconstant;
    elseif all(constant == 'Power')
        Fconstant = sqrt(8*real([dynModel(i).Zi]));
        dynModel(i).F0 = Fconstant(:,1);        
    end
    if ~all(constant == 'Spect')
        dynModel(i).eta_fd = dynModel(i).F0 ./ dynModel(i).Hex;
    end
    perform(i) = simulateDevice(dynModel(i), controlType{1}, ...
                                'interpMethod','nearest',    ...
                                'Zmax',zmax, 'Fmax',fmax);
end

%% Plot the parametric meshes
plotMesh=false;
if plotMesh == true
%WecOptTool.plot.plotMesh(mesh)
for ii = 1:length(AR)
    WecOptTool.plot.plotMesh(meshes(ii))
end    
end
 

%% Plot mass ratio
fig = figure('name','Mass Ratio');
hold on
grid on
set(gca, 'fontsize',16);
semilogx(AR,[dynModel.mass] ./( [deviceHydro.Vo] .* [deviceHydro.rho] ), ...
        '--xk' )
set(gca,'XScale','log')
%ylim([0 1])
xlabel('Aspect Ratio [-]')
ylabel('Mass ratio, m^\prime/m [-]')
saveas(fig, 'plots/massRatios.pdf')


%% Plot hydro
%close all
clear ax

[xp,yp] = meshgrid(w,AR);

flag3D=false;
%flag3D=true;

% Figure 1: Added Mass
nFig = 1;
fh(nFig) = figure('name','Radiation added mass (A)');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on
grid on
A = [dynModel.A]-[dynModel.Ainf];
if flag3D == 1
    surf(xp',yp',(A));
    rotate3d on
else
    contourf(xp',yp',(A));
    c(nFig) = colorbar;
end


% Figure 2: Radiation Damping
nFig = nFig + 1;
fh(nFig) = figure('name','Radiation wave damping (B)');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on
grid on
if flag3D == 1
    surf(xp',yp',[dynModel.B])
    rotate3d on
else
    contourf(xp',yp',[dynModel.B])
    c(nFig) = colorbar;
end


% Figure 3: Position
nFig = nFig + 1;
fh(nFig) = figure('name','|Position|');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on
grid on

if flag3D == 1
    surf(xp',yp', abs([perform.pos]) )
    rotate3d on
else
    contourf(xp',yp', abs([perform.pos]))% ./max(max(abs([perform.pos]))))
    c(nFig) = colorbar;
    set(gca,'ColorScale','log')
end


% Figure 4: Power
nFig = nFig + 1;
fh(nFig) = figure('name','|\Re(Power)|');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on
grid on
% surf(xp',yp',abs(Ex)./max(max(abs(Ex))))
Popt = abs([dynModel.Hex].*SS.S).^2./(8*real([dynModel.Zi]));
Popt(~isfinite(Popt)) = 0;
%surf(xp',yp',Popt./max(max(Popt)))

if flag3D == 1
    surf(xp',yp',abs(real([perform.pow])) )
    rotate3d on
else
    contourf(xp',yp',abs(real([perform.pow])) )
    c(nFig) = colorbar;
    set(gca,'ColorScale','log')
end


% Figure 5: Zpto
nFig = nFig + 1;
fh(nFig) = figure('name','|Zpto|');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on
grid on
%surf(xp',yp',abs([perform.Zpto])./max(max(abs([perform.Zpto]))))
if flag3D == 1
    surf(xp',yp',abs([perform.Zpto]))
    rotate3d on
else
    contourf(xp',yp',abs([perform.Zpto]))
    c(nFig) = colorbar;
    set(gca,'ColorScale','log')
end


% Figure 6: Real Zpto
nFig = nFig + 1;
fh(nFig) = figure('name','Real(Zpto)');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on
grid on
if flag3D == 1
    surf(xp',yp',real([perform.Zpto]) )
    rotate3d on
else
    contourf(xp',yp',real([perform.Zpto]) )
    c(nFig) = colorbar;
end


% Figure 7: Imag Zpto
nFig = nFig + 1;
fh(nFig) = figure('name','Im(Zpto)');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on
grid on

if flag3D == 1
    surf(xp',yp',imag([perform.Zpto]) )
    surf(xp',yp',zeros(size(xp')),'FaceAlpha',0.25,'EdgeColor','none',...
     'FaceColor','blue')
    rotate3d on
else
    contourf(xp',yp',imag([perform.Zpto]) )
    c(nFig) = colorbar;
end

% Figure 8: Velocity
nFig = nFig + 1;
fh(nFig) = figure('name','|Velocity|');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on
grid on

if flag3D == 1
    surf(xp',yp',abs([perform.u]) )
    rotate3d on
else
    contourf(xp',yp',abs([perform.u]) )
    c(nFig) = colorbar;
    set(gca,'ColorScale','log')
end


% Figure 9: eta_fd
nFig = nFig + 1;
fh(nFig) = figure('name','|\eta_{fd}|');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on
grid on
eta = [dynModel.eta_fd];
if flag3D == 1
    surf(xp(:,:)',yp(:,:)',abs(eta(:,:) ) )% ./ max(max((abs([eta])))))
    set(ax(nFig),'zscale','log')
    rotate3d on
else
    contourf(xp(:,:)',yp(:,:)',abs(eta(:,:) ) )% ./ max(max((abs([eta])))))
    c(nFig) = colorbar;    
    set(gca,'ColorScale','log')
end


% Figure 10: Fex
nFig = nFig + 1;
fh(nFig) = figure('name','|F_{Ex}|');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on

if flag3D == 1
    surf(xp',yp',abs([perform.F0]))
    set(ax(nFig),'zscale','log')
    rotate3d on
else
    contourf(xp(:,:)',yp(:,:)',abs([perform.F0]) )
    c(nFig) = colorbar;    
    set(gca,'ColorScale','log')
end


% Figure 11: Zi
nFig = nFig + 1;
fh(nFig) = figure('name','|Z_{i}|');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on

if flag3D == 1
    surf(xp',yp',abs([dynModel.Zi]))
    set(ax(nFig),'zscale','log')
    rotate3d on
else
    contourf(xp(:,:)',yp(:,:)',abs([dynModel.Zi]) )
    c(nFig) = colorbar;    
    set(gca,'ColorScale','log')
end


% Figure 12: Hex
nFig = nFig + 1;
fh(nFig) = figure('name','H_{ex}');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on

if flag3D == 1
    surf(xp',yp',abs([dynModel.Hex]))
    set(ax(nFig),'zscale','log')
    rotate3d on
else
    contourf(xp(:,:)',yp(:,:)',abs([dynModel.Hex]) )
    c(nFig) = colorbar;    
    set(gca,'ColorScale','log')
end

% Figure 13: Reactive Power
nFig = nFig + 1;
fh(nFig) = figure('name','|\Im(Power)|');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on

if flag3D == 1
    surf(xp',yp',imag([perform.pow])) 
    rotate3d on
else
    contourf(xp',yp',abs(imag([perform.pow])))
    c(nFig) = colorbar;
    set(gca,'ColorScale','log')
end


if flag3D == 1
    Link = linkprop(ax, ...
           {'CameraUpVector', 'CameraPosition', 'CameraTarget'});
    setappdata(gcf, 'StoreTheLink', Link);
    view([20, 12])
end


for ii = 1:nFig
    xlabel(ax(ii),'Freq. [rad/s]')
    ylabel(ax(ii),'Aspect ratio [ ]')
    if flag3D==1
        zlabel(ax(ii),fh(ii).Name)
    else
        c(ii).Label.String = fh(ii).Name;
    end
    %fname = strrep(strrep(strrep(strrep(fh(ii).Name,'|',''), '\',''), '{',''),'}','');
    fname = strrep(fh(ii).Name,'|','');
    path = "plots/%s/%s.pdf";
    
    str = sprintf(path,constant,fname);
    saveas(fh(ii), str)
end


%% Plot omega, Zi for each AR (2D)
nFig = nFig + 1;
fh(nFig) = figure('name','Z_{i}');
ax(nFig) = gca;
set(gca, 'fontsize',16);
hold on
grid 
for ii = 1:length(AR)
    plot(xp(ii,:)',abs([dynModel(ii).Zi]), 'DisplayName',string(AR(ii)))    
end   
xlabel('Freq. [rad/s]')
ylabel('Z_i [\Omega]')
legend()


%% Plot omega, Zi for each AR (2D)
nFig = nFig + 1;
fh(nFig) = figure('name','Z_{i}');
ax(nFig) = gca;
set(gca, 'fontsize',16);
set(gca, 'yscale','log');
hold on
grid 
for ii = 1:length(AR)
    plot(w',abs(imag([dynModel(ii).Zi])), 'DisplayName',string(AR(ii)))    
end   
xlabel('Freq. [rad/s]')
ylabel('')
legend()

%% Bode 
hold on

for ii = 1:length(AR)
    bode(frd(dynModel(ii).Zi,w)),  
end   
xlabel('Freq. [rad/s]')
xlim([0.3,11])
grid 
legendCell = cellstr(num2str(AR'));
legend(legendCell)

