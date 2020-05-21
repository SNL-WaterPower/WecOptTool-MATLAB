classdef Damping < WecOptLib.experimental.blocks.Control
    
    methods
        
        function performance = getPerfomance(obj, motion, S)
            
            % Frequencies
            freqs = motion.w;

            % Max Power for a given Damping Coeffcient [Falnes 2002 
            % (p.51-52)]
            P_max = @(b) -0.5*b*sum(abs(RM3.F0./(RM3.Zi+b)).^2);
            
            % Optimize the linear damping coeffcient(B)
            B_opt = fminsearch(P_max, max(real(RM3.Zi)));

            % Power per frequency at optimial damping?
            performance = 0.5*B_opt *(abs(RM3.F0 ./ (RM3.Zi + B_opt)).^2);
            
        end
        
    end
    
end
