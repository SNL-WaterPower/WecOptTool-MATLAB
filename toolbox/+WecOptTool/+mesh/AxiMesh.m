classdef AxiMesh < WecOptTool.base.Mesher & WecOptTool.base.NEMOH
    
    properties
        verb = false
        rho = 1025
        g = 9.81
    end
    
    methods
        
        function mesh = makeMesh(obj, r, z, ntheta, nfobj, zG, bodyNum)
            % [Mass,Inertia,KH,XB,YB,ZB] = axiMesh(r,z,n)
            %
            % Purpose : Mesh generation of an axisymmetric body for use 
            %           with Nemoh
            %
            % Inputs : description of radial profile of the body
            %   - n         : number of points for discretisation
            %   - r         : array of radial coordinates
            %   - z         : array of vertical coordinates
            %
            % Outputs : hydrostatics
            %   - Mass      : mass of buoy
            %   - Inertia   : inertia matrix (estimated assuming mass is 
            %                 distributed on wetted surface)
            %   - KH        : hydrostatic stiffness matrix
            %   - XB,YB,ZB  : coordinates of buoyancy center
            %
            % Warning : z(i) must be greater than z(i+1)
            %
            % Originally licensed under the Apache License, Version 2.0
            % Written by A. Babarit, LHEEA Lab.
            %

            import WecOptTool.types.Mesh
            
            % Throwing error message if Nemoh could not be found.
            nemohExistFlag = obj.isNemohInPath();

            if(~ nemohExistFlag)
                errMsg = ['Error: Unable to locate Nemoh binaries. ',   ...
                          'It is possible that the Nemoh path has not ',...
                          'been added to WecOptTool. Make sure that ',  ...
                          'the file path is  spelled correctly and ',   ...
                          'has been added to WecOptTool using the ',    ...
                          'InstallNemoh.m script'];
                error(errMsg);
            end
            
            startdir = pwd;
            cd(obj.folder);
            rundir = '.';
            
            if exist(fullfile(rundir,'input.txt'), 'file') ~= 2
                [fip, errmsg] = fopen(fullfile(rundir,'input.txt'),'w');
                error(errmsg);
                fwrite(fip,'0\n');
                fclose(fip);
            end

            WOTDataPath = WecOptLib.utils.getUserPath();
            configPath = fullfile(WOTDataPath, 'config.json');
            config = jsondecode(fileread(configPath));
            nemohPath = fullfile(config.nemohPath);

            if ispc
                nemoh_mesh_command = fullfile(nemohPath, 'mesh');
            else
                nemoh_mesh_command = fullfile(nemohPath, 'mesh');
            end

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

            if obj.verb
                fprintf('\n --> Number of nodes             : %g',nx);
                fprintf('\n --> Number of panels (max 2000) : %g \n',nf);
            end

             % obj.folder;

            % If this is a multi-body device the mesh and results 
            % directories will already exist
            if exist(fullfile(rundir,'mesh'),'dir') ~= 7
                mkdir(fullfile(rundir,'mesh'));
            end
            if exist(fullfile(rundir,'results'),'dir') ~= 7
                mkdir(fullfile(rundir,'results'));
            end

            % Creation des fichiers de calcul du maillage
            fid=fopen(fullfile('Mesh.cal'),'w');
            fprintf(fid,[mname,'\n'],1);
            fprintf(fid,'1 \n ');
            fprintf(fid,'0. 0. \n ');
            fprintf(fid,'%f %f %f \n',[0. 0. zG]);
            fprintf(fid,'%g \n ', nfobj);
            fprintf(fid,'2 \n ');
            fprintf(fid,'0. \n ');
            fprintf(fid,'1.\n');
            fprintf(fid,'%f \n ', obj.rho);
            fprintf(fid,'%f \n', obj.g);
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
            [status,msg] = system([nemoh_mesh_command,  ...
                                   ' >',                ...
                                   fullfile(rundir,'mesh','mesh.log')]);
            if status
                error(msg)
            else
                if obj.verb
                    fprintf(fileread(fullfile(rundir,'mesh','mesh.log')))
                end
            end
            
            meshFileName = join([mname, '.dat'], "");
            meshFilePath = fullfile(rundir, 'mesh', meshFileName);
            meshData = obj.readNEMOHMesh(meshFilePath);
            meshData.name = mname;
            meshData.zG = zG;
            meshData.bodyNum = bodyNum;
            mesh = Mesh(meshData);
            
            cd(startdir);
        
        end
        
    end
        
    methods (Static)
        
        function meshData = readNEMOHMesh(datFilePath)

            M = dlmread(datFilePath);
            zeroIdxs = find(M(:, 1) == 0);
            
            meshData.xzSymmetric = M(1, 2) == 1;
            nodes = M(2:zeroIdxs(1) - 1, :);
            meshData.nodes = table(nodes(:,1),     ...
                                   nodes(:,2),     ...
                                   nodes(:,3),     ...
                                   nodes(:,4),     ...
                                   'VariableNames', {'ID', 'x', 'y', 'z'});
            meshData.panels = M(zeroIdxs(1) + 1:zeroIdxs(2) - 1, :);
            
        end
        
    end
end

