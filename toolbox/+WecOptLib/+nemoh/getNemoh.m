function [hydro] = getNemoh(r,z,freq,rundir,varargin)
% [hydro] = getNemoh(r,z,freq,rundir)
%
% Builds axisymmetric NEMOH mesh, runs NEMOH and returns results (heave
% only). Parts borrowed from the the Matlab runner that comes with NEMOH.
%
% Input
%       r       radius points array
%       z       vertical points array
%       w       frequency (rad/s) array
%       rundir  location to create mesh, run NEMOH and store results
%
% Output
%       w       frequency array (rad/s)
%       A       A(w) array
%       Ainf    infinite added mass
%       B       B(w) array
%       Ex      complex excitation FRF
%       m       mass
%       C       hydrostatic stiffness
%
% Example (cylinder w/ radius of 5m)
%   r=[0 5 5 0];
%   z=[5 5 -5 -5];
%   rundir = '.'   % place files in current directory
%   [w,A,Ainf,B,Ex,m,C] = getNemoh(r,z,rundir);
%
% Requires
%       WEC-Sim
%       Nemoh
%
% RG Coe 2016
% adapted from
% aximesh A. Babarit, LHEEA Lab.
% &
% Penalba, Markel, Thomas Kelly, and John V. Ringwood. "Using NEMOH for
% modelling wave energy converters: A comparative study with WAMIT."
% Proceedings of the 12th European Wave and Tidal Energy Conference
% (EWTEC2017), Cork, Ireland. 2017.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
startdir = pwd;

if exist(rundir,'dir') ~= 7
    mkdir(rundir)
end

% Throwing error message if Nemoh could not be found.
nemohExistFlag = WecOptLib.nemoh.isNemohInPath(rundir);

if(~ nemohExistFlag)
    errMsg = ['Error: Unable to locate Nemoh binaries. It is ',     ...
              'possible that the Nemoh path has not been added ',   ...
              'to WecOptTool. Make sure that the file path is ',    ...
              'spelled correctly and has been added to WecOptTool ',...
              'using the InstallNemoh.m script'];
    error(errMsg);
end

cd(rundir)
rundir = '.';

WOTDataPath = WecOptLib.utils.getUserPath();
configPath = fullfile(WOTDataPath, 'config.json');
config = jsondecode(fileread(configPath));
nemohPath = fullfile(config.nemohPath);

if ispc
    nemoh_mesh_command = fullfile(nemohPath, 'mesh');
    nemoh_preProc_command = fullfile(nemohPath, 'preProcessor');
    nemoh_run_command = fullfile(nemohPath, 'solver');
    nemoh_postProc_command = fullfile(nemohPath, 'postProcessor');
else
    nemoh_mesh_command = fullfile(nemohPath, 'mesh');
    nemoh_preProc_command = fullfile(nemohPath, 'preProc');
    nemoh_run_command = fullfile(nemohPath, 'solver');
    nemoh_postProc_command = fullfile(nemohPath, 'postProc');
end

if iscell(r)
    nBody = length(r);
else
    nBody = 1;
    r = mat2cell(r,1,length(r));
    z = mat2cell(z,1,length(z));
end

p = inputParser;
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
addOptional(p,'rho',1025,@(x)validScalarPosNum(x));
addOptional(p,'g',9.81,@(x)validScalarPosNum(x));
addOptional(p,'zG',zeros(nBody,1))
addOptional(p,'ntheta',20,@(x)validScalarPosNum(x))
addOptional(p,'nfobj',200,@(x)validScalarPosNum(x))
addOptional(p,'Display',0)

parse(p,varargin{:})
rho = p.Results.rho;
g = p.Results.g;
zG = p.Results.zG;
ntheta = p.Results.ntheta;
nfobj = p.Results.nfobj;
verb = p.Results.Display;


%
% if nargin < 5
%     warning('Setting nBody = 1')
%     nBody = 1;
% end

% if exist('demo','dir') ~= 7
%     warning('rundir %s not found, creating...',rundir)
%     mkdir(rundir)
% end


if exist(fullfile(rundir,'input.txt'), 'file') ~= 2
    [fip, errmsg] = fopen(fullfile(rundir,'input.txt'),'w');
    error(errmsg);
    fwrite(fip,'0\n');
    fclose(fip);
end

for ii = 1:nBody
    [meshNames{ii},Mass{ii},Inertia{ii},KH{ii},XB{ii},...
        YB{ii},ZB{ii},nx{ii},nf{ii}] = ...
        axiMesh(r{ii},z{ii},ntheta,nfobj,zG(ii),ii);
end

writeNemohCal(meshNames,nx,nf)

nemohCall(nemoh_preProc_command);
nemohCall(nemoh_run_command);
nemohCall(nemoh_postProc_command);

hydro = struct();
hydro = WecOptLib.vendor.WEC_Sim.Read_NEMOH(hydro, rundir);

cd(startdir)

% Cn = C/(rho*g);   Linear restoring stiffness
% An = A/rho;       Added mass
% Bn = B/(rho*w);   Radiation damping
% Xn = X/(rho*g);   Excitation force

% m = hydro.Vo * rho;
% w = hydro.w;
% A = squeeze(hydro.A(3,3,:))*rho;
% Ainf = hydro.Ainf(3,3)*rho;
% B = squeeze(hydro.B(3,3,:)).*w'*rho;
% Ex = (squeeze(hydro.ex_re(3,1,:)) + 1i * squeeze(hydro.ex_im(3,1,:)))*rho*g;
% C = hydro.C(3,3)*rho*g;



    function [status,msg] = nemohCall(command)
        if verb
            fprintf('Running Nemoh %s\n',command);
        end
        [status,msg] = system(command);
        if status
            error(msg)
        else
            if verb
                disp(msg)
            end
        end
    end

    function [] = writeNemohCal(meshNames,nx,nf)
        
        nBody = length(meshNames);
        
        fid=fopen(fullfile(rundir,'Nemoh.cal'),'w');
        fprintf(fid,'--- Environment ------------------------------------------------------------------------------------------------------------------\n');
        fprintf(fid,'%f				! RHO 			! KG/M**3 	! Fluid specific volume \n',rho);
        fprintf(fid,'%f				! G			! M/S**2	! Gravity \n',g);
        fprintf(fid,'0.                 ! DEPTH			! M		! Water depth\n');
        fprintf(fid,'0.	0.              ! XEFF YEFF		! M		! Wave measurement point\n');
        fprintf(fid,'--- Description of floating bodies -----------------------------------------------------------------------------------------------\n');
        fprintf(fid,'%d				! Number of bodies\n',nBody);
        for jj = 1:nBody
            fprintf(fid,'--- Body %i ----------------------------------------------------------------------------------------------------------------------\n',ii);
                
            if ispc
                fprintf(fid,['''',rundir,filesep,filesep,'mesh',filesep,filesep,meshNames{jj},'.dat''		! Name of mesh file\n']);
            else
                fprintf(fid,['''',rundir,filesep,'mesh',filesep,meshNames{jj},'.dat''		! Name of mesh file\n']);
            end
            
            fprintf(fid,'%g %g			            ! Number of points and number of panels 	\n',nx{jj},nf{jj});
            fprintf(fid,'6				            ! Number of degrees of freedom\n');
            fprintf(fid,'1 1. 0.	0. 0. 0. 0.     ! Surge\n');
            fprintf(fid,'1 0. 1.	0. 0. 0. 0.     ! Sway\n');
            fprintf(fid,'1 0. 0. 1. 0. 0. 0.		! Heave\n');
            fprintf(fid,'2 1. 0. 0. 0. 0. %f		! Roll about a point\n',zG(jj));
            fprintf(fid,'2 0. 1. 0. 0. 0. %f		! Pitch about a point\n',zG(jj));
            fprintf(fid,'2 0. 0. 1. 0. 0. %f		! Yaw about a point\n',zG(jj));
            fprintf(fid,'6				            ! Number of resulting generalised forces\n');
            fprintf(fid,'1 1. 0.	0. 0. 0. 0.		! Force in x direction\n');
            fprintf(fid,'1 0. 1.	0. 0. 0. 0.		! Force in y direction\n');
            fprintf(fid,'1 0. 0. 1. 0. 0. 0.		! Force in z direction\n');
            fprintf(fid,'2 1. 0. 0. 0. 0. %f		! Moment force in x direction about a point\n',zG(jj));
            fprintf(fid,'2 0. 1. 0. 0. 0. %f		! Moment force in y direction about a point\n',zG(jj));
            fprintf(fid,'2 0. 0. 1. 0. 0. %f		! Moment force in z direction about a point\n',zG(jj));
            fprintf(fid,'0				            ! Number of lines of additional information \n');
        end
        fprintf(fid,'--- Load cases to be solved -------------------------------------------------------------------------------------------------------\n');
        fprintf(fid,'%i	%.2f %.2f		            ! Number of wave frequencies, Min, and Max (rad/s)\n',length(freq),freq(1),freq(end));
        fprintf(fid,'1	0.	0.                      ! Number of wave directions, Min and Max (degrees)\n');
        fprintf(fid,'--- Post processing ---------------------------------------------------------------------------------------------------------------\n');
        fprintf(fid,'0	0.1	10.                     ! IRF 				! IRF calculation (0 for no calculation), time step and duration\n');
        fprintf(fid,'0                              ! Show pressure\n');
        fprintf(fid,'0	0.	180.                    ! Kochin function 		! Number of directions of calculation (0 for no calculations), Min and Max (degrees)\n');
        fprintf(fid,'0	50	400.	400.            ! Free surface elevation 	! Number of points in x direction (0 for no calcutions) and y direction and dimensions of domain in x and y direction\n');
        fprintf(fid,'---');
        status=fclose(fid);
    end

    function [mname,Mass,Inertia,KH,XB,YB,ZB,nx,nf] = axiMesh(r,z,ntheta,nfobj,zG,bodyNum)
        % [Mass,Inertia,KH,XB,YB,ZB]=axiMesh(r,z,n)
        %
        % Purpose : Mesh generation of an axisymmetric body for use with Nemoh
        %
        % Inputs : description of radial profile of the body
        %   - n         : number of points for discretisation
        %   - r         : array of radial coordinates
        %   - z         : array of vertical coordinates
        %
        % Outputs : hydrostatics
        %   - Mass      : mass of buoy
        %   - Inertia   : inertia matrix (estimated assuming mass is distributed on
        %   wetted surface)
        %   - KH        : hydrostatic stiffness matrix
        %   - XB,YB,ZB  : coordinates of buoyancy center
        %
        % Warning : z(i) must be greater than z(i+1)
        %
        % Copyright Ecole Centrale de Nantes 2014
        % Licensed under the Apache License, Version 2.0
        % Written by A. Babarit, LHEEA Lab.
        %
        n = length(r);
        mname = sprintf('axisym_%i',bodyNum);
%         status=close('all');
        theta=[0.:pi/(ntheta-1):pi];
        nx=0;
        % Calcul des sommets du maillage
        for j=1:ntheta
            for i=1:n
                nx=nx+1;
                x(nx)=r(i)*cos(theta(j));
                y(nx)=r(i)*sin(theta(j));
                z(nx)=z(i);
            end
        end
        % Calcul des facettes
        nf=0;
        for i=1:n-1
            for j=1:ntheta-1
                nf=nf+1;
                NN(1,nf)=i+n*(j-1);
                NN(2,nf)=i+1+n*(j-1);
                NN(3,nf)=i+1+n*j;
                NN(4,nf)=i+n*j;
            end
        end
        % Affichage de la description du maillage
        nftri=0;
        for i=1:nf
            nftri=nftri+1;
            tri(nftri,:)=[NN(1,i) NN(2,i) NN(3,i)];
            nftri=nftri+1;
            tri(nftri,:)=[NN(1,i) NN(3,i) NN(4,i)];
        end
        
        %         figure
        %         trimesh(tri,x,y,z,[zeros(nx,1)]);
        %         title('Characteristics of the discretisation');
        %         axis equal
        
        if verb
            fprintf('\n --> Number of nodes             : %g',nx);
            fprintf('\n --> Number of panels (max 2000) : %g \n',nf);
        end
        
        % If this is a multi-body device the mesh and results directories
        % will already exist
        if exist(fullfile(rundir,'mesh'),'dir') ~= 7
            mkdir(fullfile(rundir,'mesh'));
        end
        if exist(fullfile(rundir,'results'),'dir') ~= 7
            mkdir(fullfile(rundir,'results'));
        end
        
        
        % Creation des fichiers de calcul du maillage
        fid=fopen(fullfile('Mesh.cal'),'w');
        fprintf(fid,[mname,'\n'],1);
        fprintf(fid,'1 \n 0. 0. \n ');
        fprintf(fid,'%f %f %f \n',[0. 0. zG]);
        fprintf(fid,'%g \n 2 \n 0. \n 1.\n',nfobj);
        fprintf(fid,'%f \n %f \n',[rho g]);
        status=fclose(fid);

        fid=fopen(fullfile('ID.dat'),'w');
        fprintf(fid,['% g \n',rundir,' \n'],length(rundir));
        status=fclose(fid);
        fid=fopen(fullfile(rundir,'mesh',mname),'w');
        fprintf(fid,'%g \n',nx);
        fprintf(fid,'%g \n',nf);
        for i=1:nx
            fprintf(fid,'%E %E %E \n',[x(i) y(i) z(i)]);
        end
        for i=1:nf
            fprintf(fid,'%g %g %g %g \n',NN(:,i)');
        end
        status=fclose(fid);
        
        % Raffinement automatique du maillage et calculs hydrostatiques
        [status,msg] = system([nemoh_mesh_command, ' >',fullfile(rundir,'mesh','mesh.log')]);
        if status
            error(msg)
        else
            if verb
                fprintf(fileread(fullfile(rundir,'mesh','mesh.log')))
            end
        end
        
        % Visualisation du maillage
        clear x y z NN nx nf nftri tri u v w;
        fid=fopen(fullfile(rundir,'mesh',[mname,'.tec']),'r');
        ligne=fscanf(fid,'%s',2);
        nx=fscanf(fid,'%g',1);
        ligne=fscanf(fid,'%s',2);
        nf=fscanf(fid,'%g',1);
        ligne=fgetl(fid);
        
        if verb
            fprintf('\n Characteristics of the mesh for Nemoh \n');
            fprintf('\n --> Number of nodes : %g',nx);
            fprintf('\n --> Number of panels : %g\n \n',nf);
        end

        for i=1:nx
            ligne=fscanf(fid,'%f',6);
            x(i)=ligne(1);
            y(i)=ligne(2);
            z(i)=ligne(3);
        end
        for i=1:nf
            ligne=fscanf(fid,'%g',4);
            NN(1,i)=ligne(1);
            NN(2,i)=ligne(2);
            NN(3,i)=ligne(3);
            NN(4,i)=ligne(4);
        end
        nftri=0;
        for i=1:nf
            nftri=nftri+1;
            tri(nftri,:)=[NN(1,i) NN(2,i) NN(3,i)];
            nftri=nftri+1;
            tri(nftri,:)=[NN(1,i) NN(3,i) NN(4,i)];
        end
        ligne=fgetl(fid);
        ligne=fgetl(fid);
        for i=1:nf
            ligne=fscanf(fid,'%g %g',6);
            xu(i)=ligne(1);
            yv(i)=ligne(2);
            zw(i)=ligne(3);
            u(i)=ligne(4);
            v(i)=ligne(5);
            w(i)=ligne(6);
        end
        status=fclose(fid);
        
        ff = figure('visible',verb);
        trimesh(tri,x,y,z);
        hold on
        quiver3(xu,yv,zw,u,v,w);
        title('Mesh for Nemoh');
        axis equal
        fign = fullfile(fullfile(rundir,'mesh','mesh.fig'));
        savefig(fign);
        
        clear KH;
        KH=zeros(6,6);
        fnKh = fullfile(rundir,'mesh','KH.dat');
        fid=fopen(fnKh,'r');
        for i=1:6
            ligne=fscanf(fid,'%g %g',6);
            KH(i,:)=ligne;
        end
        status=fclose(fid);
        
        clear XB YB ZB Mass WPA Inertia
        Inertia=zeros(6,6);
        fnhs = fullfile(rundir,'mesh',sprintf('Hydrostatics.dat'));
        fid = fopen(fnhs,'r');
        ligne = fscanf(fid,'%s',2);
        XB = fscanf(fid,'%f',1);
        ligne = fgetl(fid);
        ligne = fscanf(fid,'%s',2);
        YB = fscanf(fid,'%f',1);
        ligne = fgetl(fid);
        ligne = fscanf(fid,'%s',2);
        ZB = fscanf(fid,'%f',1);
        ligne = fgetl(fid);
        ligne = fscanf(fid,'%s',2);
        Mass = fscanf(fid,'%f',1)*rho;
        ligne = fgetl(fid);
        ligne =fscanf(fid,'%s',2);
        WPA=fscanf(fid,'%f',1);
        status=fclose(fid);
        clear ligne
        
        fnIn = fullfile(rundir,'mesh','Inertia_hull.dat');
        fid=fopen(fnIn,'r');
        for i=1:3
            ligne=fscanf(fid,'%g %g',3);
            Inertia(i+3,4:6)=ligne;
        end
        Inertia(1,1)=Mass;
        Inertia(2,2)=Mass;
        Inertia(3,3)=Mass;
        
        fclose('all');
        
        if nBody > 1
            movefile(fnhs,...
                fullfile(rundir,'mesh',sprintf('Hydrostatics_%i.dat',bodyNum-1)))
            movefile(fnKh,...
                fullfile(rundir,'mesh',sprintf('KH_%i.dat',bodyNum-1)));
            movefile(fnIn,...
                fullfile(rundir,'mesh',sprintf('Inertia_hull_%i.dat',bodyNum-1)));
            movefile(fign,...
                fullfile(rundir,'mesh',sprintf('mesh_%i.fig',bodyNum-1)));
        end
    end
end
