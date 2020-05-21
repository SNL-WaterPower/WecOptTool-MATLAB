classdef Model < WecOptLib.experimental.blocks.Model
    
    methods
        
        function static = getStatic(obj, hydro)
            
            % Mass
            static.mass1 = hydro.Vo(1) * hydro.rho;
            static.mass2 = hydro.Vo(2) * hydro.rho;

            % Restoring
            static.K3 = hydro.C(3,3,1) * hydro.g * hydro.rho;
            static.K9 = hydro.C(3,3,2) * hydro.g * hydro.rho;
            
        end
        
        function dynamic = getDynamic(obj, static, hydro, S)
            
            function result = interp_mass(hydro, dof1, dof2, w)
                result = interp1(hydro.w,                           ...
                                 squeeze(hydro.A(dof1, dof2, :)),   ...
                                 w,                                 ...
                                 'linear',                          ...
                                 0);
            end
            
            function result = interp_rad(hydro, dof1, dof2, w)
                result = interp1(hydro.w,                           ...
                                 squeeze(hydro.B(dof1, dof2, :)),   ...
                                 w,                                 ...
                                 'linear',                          ...
                                 0);
            end
            
            function result = interp_ex(hydro, dof, w)
                
                h = complex(squeeze(hydro.ex_re(dof, 1, :)),   ...
                            squeeze(hydro.ex_im(dof, 1, :)));

                result = interp1(hydro.w, h ,w, 'linear', 0);
                
            end
            
            % Ignore tails of the spectra; return indicies of the 
            % vals>1% of max
            iSpec = find(S.S > 0.01*max(S.S));
            
            % Return column vector of all w between first/last indicies
            iStart = min(iSpec);
            iEnd   = max(iSpec);
            iSkip  = 1;
            w = S.w(iStart:iSkip:iEnd);
            
            % Calculate w step-size
            if length(iSpec) == 1
                dw = wStep;    
            else    
                dw = mean(diff(S.w))*iSkip;   
            end

            % Get column vector S at same indicies as w (Removed 
            % interpolation). 
            s = S.S(iStart:iSkip:iEnd);
            
            % TODO: is interp needed?
            % s = interp1(S.w(:), S.S, w,'linear',0);
            % Calculate wave amplitude
            waveAmp = sqrt(2 * dw * s);
            
            % Row vector of random phases?
            ph = rand(length(s), 1);
            
            % Wave height in frequency domain
            eta_fd = waveAmp .* exp(1i*ph);
            eta_fd = eta_fd(:);

            % Radiation impedance matrix: B + iwA
            % A: Added Mass
            % B: Damping 
            B99 = interp_rad(hydro, 9, 9, w) * hydro.rho .* w;
            A99 = interp_mass(hydro, 9, 9, w) * hydro.rho;

            B39 = (interp_rad(hydro, 3, 9, w) + ...
                        interp_rad(hydro, 9, 3, w)) / 2 * hydro.rho .* w;
            A39 = (interp_mass(hydro, 3, 9, w) + ...
                        interp_mass(hydro, 9, 3, w)) / 2 * hydro.rho;
            
            B33 = interp_rad(hydro, 3, 3, w) * hydro.rho .* w;
            A33 = interp_mass(hydro, 3, 3, w) * hydro.rho;
            
            % Excitation
            H3 = interp_ex(hydro, 3, w) * hydro.g * hydro.rho;
            H9 = interp_ex(hydro, 9, w) * hydro.g * hydro.rho;

            % Excitation Forces
            E3 = H3 .* eta_fd;
            E9 = H9 .* eta_fd;

            % friction
            % Add some friction proportional to the max radiation damping 
            % term
            Bf = max(B33) * 0.1;

            % Calculate Impedance
            Z3 = B33 + Bf + 1i * ( ...
                        w .* (static.mass1 + A33) - static.K3 ./ w);
            Z9 = B99 + Bf + 1i * ( ...
                        w .* (static.mass2 + A99) - static.K9 ./ w);
                    
            % Hydrodynamic radiation coupling between the two bodies 
            % [Falnes 1999].       
            Zc = B39 + 1i * w .* A39;

            % External Impedance
            Z0 = Z3 + Z9 + 2*Zc;
            
            % Intrinsic Impedance
            Zi = (Z3.*Z9 - Zc.^2) ./ Z0;
            
            % Excitation Force
            F0 = (E3.*(Z9+Zc) - E9 .* (Z3 + Zc)) ./ Z0;

            dynamic.w = w;
            dynamic.dw = dw;
            dynamic.wave_amp = waveAmp;
            dynamic.ph = ph;
            dynamic.B99 = B99;
            dynamic.A99 = A99;
            dynamic.B39 = B39;
            dynamic.A39 = A39;
            dynamic.B33 = B33;
            dynamic.A33 = A33;
            dynamic.H3 = H3;
            dynamic.H9 = H9;
            dynamic.E3 = E3;
            dynamic.E9 = E9;
            dynamic.Bf = Bf;
            dynamic.Z3 = Z3;
            dynamic.Z9 = Z9;
            dynamic.Zc = Zc;
            dynamic.Z0 = Z0;
            dynamic.Zi = Zi;
            dynamic.F0 = F0;
            
        end
        
    end
    
end
