
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

function [pow, powPerFreq] = getPSPhasePower(motion, ph)
    %Calculates power using the pseudospectral method given a phase and
    % a descrption of the body movement. Returns total phase power and 
    % power per frequency 
    
    function P = pow_calc(X)
        P = X' * motion.H_mat * X;
    end
    
    eta_fd = motion.wave_amp .* exp(1i*ph);
    %             eta_fd = eta_fd(start:end);
    
    fef3 = zeros(2*motion.Nf,1);
    fef9 = zeros(2*motion.Nf,1);
    
    E3 = motion.H3 .* eta_fd;
    E9 = motion.H9 .* eta_fd;
    
    fef3(1:2:end) =  real(E3);
    fef3(2:2:end) = -imag(E3);
    fef9(1:2:end) =  real(E9);
    fef9(2:2:end) = -imag(E9);
    
    Beq = [fef3; fef9] / motion.m_scale;
    
    % constrained optimiztion
    qp_options = optimoptions('fmincon',                        ...
                              'Algorithm', 'sqp',               ...
                              'Display', 'off',                 ...
                              'MaxIterations', 1e3,             ...
                              'MaxFunctionEvaluations', 1e5,    ...
                              'OptimalityTolerance', 1e-8,      ...
                              'StepTolerance', 1e-6);
    
    siz = size(motion.A_ineq);
    X0 = zeros(siz(2),1);
    [y, ~, ~, ~] = fmincon(@pow_calc,       ...
                           X0,              ...
                           motion.A_ineq,   ...
                           motion.B_ineq,   ...
                           motion.Aeq,      ...
                           Beq,             ...
                           [], [], [],      ...
                           qp_options); 
    
    % y is a vector of x1hat, x2hat, & uhat. Calculate energy using
    % Equation 6.11 of Bacelli 2014
    uEnd = numel(y);
    x1End = uEnd / 3;
    x2Start = x1End + 1;
    x2End = 2 * uEnd / 3;
    uStart = x2End + 1;
    
    x1hat = y(1:x1End);
    x2hat = y(x2Start:x2End);
    uhat = y(uStart:end);
    
    Pvec = -1 / 2 * (x1hat - x2hat) .* uhat;
    % Add the sin and cos components to get power as function of W
    powPerFreq = Pvec(1:2:end) + Pvec(2:2:end);
    powPerFreq = powPerFreq * motion.m_scale;
    
    velT = motion.Phip' * [x1hat;x2hat];
    body1End = numel(velT) / 2;
    Body2Start = body1End + 1;
    velTBody1 = velT(1:body1End);
    velTBody2 = velT(Body2Start:end);
    
    % posT = (motion.Phip' / motion.Dphi) * [x1hat;x2hat];
    % relative position (check constraint satisfaction)
    
    % relPosT = posT(1:end/2)- posT(end/2+1:end);
    % relative velocity (check constraint satisfaction)
    % relVelT = velT(1:end/2)- velT(end/2+1:end);
    
    % Alternative power calculation
    uT = motion.m_scale * motion.Phip1' * uhat;
    Pt = (velTBody2 - velTBody1) .* uT;
    pow = trapz(motion.tkp, Pt) / (motion.tkp(end) - motion.tkp(1));
    assert(WecOptLib.utils.isClose(pow, sum(powPerFreq)))
    
end

