
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

function [powPerFreq, freq] = pseudoSpectral(obj, motion)
    % PSEUDOSPECTRAL Pseudo spectral control
    %   Returns power per frequency and frequency bins
    
    import WecOptLib.models.RM3.*
    
    % Fix random seed <- Do we want this???
    rng(1);
    
    % Reformulate equations of motion
    motion = getPSCoefficients(motion);
    
    % Add phase realizations
    n_ph_avg = 5;
    ph_mat = 2 * pi * rand(length(motion.w), n_ph_avg); 
    n_ph = size(ph_mat, 2);
    
    freq = motion.W;
    n_freqs = length(freq);
    powPerFreqMat = zeros(n_ph, n_freqs);
    
    for ind_ph = 1 : n_ph
        
        ph = ph_mat(:, ind_ph);
        [~, phasePowPerFreq] = getPSPhasePower(motion, ph);
        
        for ind_freq = 1 : n_freqs
            powPerFreqMat(ind_ph, ind_freq) = phasePowPerFreq(ind_freq);
        end
        
    end
    
    powPerFreq = mean(powPerFreqMat);
    
end