classdef Scalar < WecOptLib.experimental.blocks.Geometry
    
    methods
        
        function hydro = getHydro(obj, lambda)
                    
            % Get data file path
            p = mfilename('fullpath');
            [filepath, ~, ~] = fileparts(p);
            dataPath = fullfile(filepath, 'RM3_BEM.mat');

            load(dataPath, 'hydro');

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
           
        end
        
    end
    
end

