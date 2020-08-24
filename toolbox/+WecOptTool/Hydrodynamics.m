classdef Hydrodynamics
    %HYDRODYNAMICS
    
    properties
        base
        ex_re
        ex_im
        g
        rho
        w
        A
        B
        C 
        Vo
        solverName
        runDirectory
    end
    
    methods
        
        function obj = Hydrodynamics(hydroData, options)
            
            arguments
                hydroData
                options.solverName = "Unknown"
                options.runDirectory = ""
            end
            
            obj.base = hydroData;
            obj.ex_re = hydroData.ex_re;
            obj.ex_im = hydroData.ex_im;
            obj.g = hydroData.g;
            obj.rho = hydroData.rho;
            obj.w = hydroData.w;
            obj.A = hydroData.A;
            obj.B = obj.checkDamping(hydroData.B);
            obj.C = hydroData.C;
            obj.Vo = hydroData.Vo;
            obj.solverName = options.solverName;
            obj.runDirectory = options.runDirectory;
            
        end
        
        function plotDamping(obj, B)
            
            arguments
                obj
                B = obj.B
            end
            
            Bdiag = cell2mat(arrayfun(@(x) diag(B(:,:,x)),     ...
                                      1:size(B, 3),            ...
                                      'UniformOutput', false));
                                   
            figure
            hold on
            grid on
            plot(obj.w, Bdiag);
            xlabel('Frequency [rad/s]')
            ylabel('Radiation damping')
            
        end
        
    end
    
    methods (Static, Access=private)
        
        function newB = checkDamping(B)
            % Checks that diagonal radiation damping always positive

            newB = B;

            for ii = 1:size(B, 1)
                Bdiag = squeeze(B(ii,ii,:));
                Bdiag(Bdiag < 0) = 0;
                newB(ii,ii,:) = Bdiag;
            end

        end
    
    end
    
end

