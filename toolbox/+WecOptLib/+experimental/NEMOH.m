classdef NEMOH < WecOptLib.experimental.base.AutoFolder
    
    properties
        verb = false
        rho = 1025
        g = 9.81
    end
    
    methods
       
        function getHydrostatics(obj, mesh, rundir)
            % Originally licensed under the Apache License, Version 2.0
            % Written by A. Babarit, LHEEA Lab.
            
            % Throwing error message if Nemoh could not be found.
            nemohExistFlag = WecOptLib.nemoh.isNemohInPath();

            if(~ nemohExistFlag)
                errMsg = ['Error: Unable to locate Nemoh binaries. It is ',     ...
                          'possible that the Nemoh path has not been added ',   ...
                          'to WecOptTool. Make sure that the file path is ',    ...
                          'spelled correctly and has been added to WecOptTool ',...
                          'using the InstallNemoh.m script'];
                error(errMsg);
            end
            
            startdir = pwd;
            cd(rundir);
            rundir = '.';

            WOTDataPath = WecOptLib.utils.getUserPath();
            configPath = fullfile(WOTDataPath, 'config.json');
            config = jsondecode(fileread(configPath));
            nemohPath = fullfile(config.nemohPath);

            if ispc
                nemoh_mesh_command = fullfile(nemohPath, 'mesh');
            else
                nemoh_mesh_command = fullfile(nemohPath, 'mesh');
            end
            
            mname = mesh.name;
            nx = height(mesh.nodes);
            nf = size(mesh.panels, 1);
            
            if obj.verb
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
            fprintf(fid,'1 \n ');
            fprintf(fid,'0. 0. \n ');
            fprintf(fid,'%f %f %f \n',[0. 0. mesh.zG]);
            fprintf(fid,'%g \n ', nf);
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
                fprintf(fid,'%E %E %E \n',mesh.nodes{i,{'x','y','z'}});
            end
            for i=1:nf
                fprintf(fid,'%g %g %g %g \n',mesh.panels(i, :));
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
            
            meshpath = @(x) fullfile(rundir, 'mesh', x);

            if isprop(mesh, 'bodyNum')
                
                fnhs = meshpath('Hydrostatics.dat');
                fnKh = meshpath('KH.dat');
                fnIn = meshpath('Inertia_hull.dat');
                
                i = mesh.bodyNum - 1;
                hydro = sprintf('Hydrostatics_%i.dat', i);
                kh = sprintf('KH_%i.dat', i);
                ih = sprintf('Inertia_hull_%i.dat', i);
                
                movefile(fnhs, meshpath(hydro))
                movefile(fnKh, meshpath(kh));
                movefile(fnIn, meshpath(ih));
                
            end
            
            % Remove mesh file
            delete(meshpath(sprintf('%s.dat', mname)));
            
            cd(startdir);
            
        end
        
    end
    
    methods (Static)
        
        function writeMeshFile(mesh, path)
            
            fid = fopen(path, 'w');
            fprintf(fid, ' %20i %10i\n', [2, mesh.xzSymmetric]);
            nodefmt = ' %13i %23.7f %23.7f %23.7f\n';
            
            for i = 1:height(mesh.nodes)
                fprintf(fid, nodefmt, mesh.nodes{i, :});
            end
            
            fprintf(fid, ' %13i %13.2f %13.2f %13.2f\n', [0, 0, 0, 0]);
            
            panelfmt = ' %15i %15i %15i %15i\n';
            
            for i = 1:size(mesh.panels, 1)
                fprintf(fid, panelfmt, mesh.panels(i, :));
            end
            
            fprintf(fid, ' %10i %10i %10i %10i\n', [0, 0, 0, 0]);
            
            status = fclose(fid);
            
        end
        
    end
    
end

