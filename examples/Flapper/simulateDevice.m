function [performance, dynModel] = simulateDevice(I,            ...
                                                  hydro,        ...
                                                  seastate,     ...
                                                  controlType,  ...
                                                  options)
                                              
    
    arguments
        I (1, 1) double
        hydro (1,1) WecOptTool.Hydrodynamics
        seastate (1,:) WecOptTool.SeaState
        controlType (1,1) string
        options.mass (1, 1) double = hydro.Vo * hydro.rho
        options.Zmax (1,:) double  = Inf % TODO - can be assymetric, need to check throughout
        options.Fmax (1,:) double = Inf
        options.interpMethod (1,1) string = 'linear'
    end
    
    dynModel = getDynamicsModel(I,         ...
                                hydro,          ...
                                seastate,       ...
                                options.interpMethod);
    
    switch controlType
        case 'CC'
            performance = complexCongugateControl(dynModel);
%         case 'P'
%             performance = dampingControl(dynModel);
%         case 'PS'
%             performance = psControl(dynModel,options.Zmax, options.Fmax);
    end

end
        
function dynModel = getDynamicsModel(I,         ...
                                     hydro,     ...
                                     SS,        ...
                                     interpMethod)
    
    function result = toVector(matrix)
        result = squeeze(matrix(1, 1, :));
    end

    % Moment of interia
    

    % Restoring (in roll)
    K = hydro.C(4,4) * hydro.g * hydro.rho;

    w = hydro.w(:);
    dw = w(2) - w(1);
    
    % Calculate wave amplitude
    waveAmpSS = SS.getAmplitudeSpectrum();
    waveAmp = interp1(SS.w, waveAmpSS, w, interpMethod, 'extrap');

    % Row vector of random phases
    ph = rand(size(waveAmp));

    % Wave height in frequency domain
    eta_fd = waveAmp .* exp(1i * ph);
    eta_fd = eta_fd(:);
    
    % radiation damping FRF
    B = toVector(hydro.B) * hydro.rho .* w;

    % added mass FRF
    A = toVector(hydro.A) * hydro.rho;

    % friction
    Bf = max(B) * 0.1;      % TODO - make this adjustable

    % intrinsic impedance
    Zi = B + Bf + 1i * (w .* (I + A) - K ./ w);

    % Excitation Forces
    Hex = toVector(hydro.ex) * hydro.g * hydro.rho;
    F0 = Hex .* eta_fd;

    dynModel.I = I;
    dynModel.K = K;
    dynModel.w = w;
    dynModel.eta_fd = eta_fd;
    dynModel.dw = dw;
    dynModel.wave_amp = waveAmp;
    dynModel.ph = ph;
    dynModel.B = B;
    dynModel.A = A;
    dynModel.Bf = Bf;
    dynModel.Zi = Zi;
    dynModel.Hex = Hex;
    dynModel.F0 = F0;
    
end

function myPerf = complexCongugateControl(dynModel,~)
    
    myPerf = Performance();
            
    myPerf.Zpto = conj(dynModel.Zi);
    
    % velocity
    myPerf.u = dynModel.F0 ./ (myPerf.Zpto + dynModel.Zi);
    
    % position
    myPerf.pos = myPerf.u ./ (1i * dynModel.w);
    
    % PTO force
    myPerf.Fpto = -1 * myPerf.Zpto .* myPerf.u;
    
    % power
    myPerf.pow = 0.5 * myPerf.Fpto .* conj(myPerf.u);
    
    myPerf.ph = dynModel.ph;
    myPerf.w = dynModel.w;
    myPerf.eta = dynModel.eta_fd;
    myPerf.F0 = dynModel.F0;

end

% Copyright 2020 National Technology & Engineering Solutions of Sandia, 
% LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
% U.S. Government retains certain rights in this software.
%
% This file is part of WecOptTool.
% 
%     WecOptTool is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     WecOptTool is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with WecOptTool.  If not, see <https://www.gnu.org/licenses/>.
