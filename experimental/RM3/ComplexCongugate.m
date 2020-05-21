classdef ComplexCongugate < WecOptLib.experimental.blocks.Control
    
    methods
        
        function performance = getPerfomance(obj, motion, S)
            
            % Frequencies
            freqs = motion.w;

            % Maximum absorbed power
            % Note: Re{Zi} = Radiation Damping Coeffcient
            performance = abs(motion.F0) .^ 2 ./ (8 * real(motion.Zi));
            
        end
        
    end
    
end
