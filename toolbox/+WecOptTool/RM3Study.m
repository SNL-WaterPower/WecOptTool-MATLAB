
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

classdef RM3Study < handle
    % Interface for preparing, executing and inspecting a simulation based 
    % on the RM3 device
    
    properties
        
        % Needs to be private to the user but public to run
        spectra
        controlType
        geomMode
        controlParams
        geomLowerBound
        geomUpperBound
        geomX0
        out
        
    end
    
    methods
        
        function obj = addControl(obj, controlObj)
            % Add a controller type to the simulation
            % 
            % Args:
            %     controlObj (WecOptTool.control.AbsControl):
            %          Controller specification object
            
            obj.controlType = controlObj.controlType;
            obj.controlParams = controlObj.controlParams;
            
        end
        
        function obj = addGeometry(obj, geomObj)
            % Add a design variable type to the simulation
            % 
            % Args:
            %     geomObj (WecOptTool.control.AbsGeom):
            %          Design variable geometry specification object
            
            obj.geomMode = geomObj.geomMode;
            obj.geomLowerBound = geomObj.geomLowerBound;
            obj.geomUpperBound = geomObj.geomUpperBound;
            obj.geomX0 = geomObj.geomX0;
        end
        
        function obj = addSpectra(obj, spectra)
            % Add a spectra to the simulation
            %
            % A single spectrum or weighted multi-spectra sea-states can
            % be simulated.
            % 
            % Args:
            %     spectra (:obj:`struct`):
            %         spectrum structure (can be arrary) in WAFO with the
            %         fields:
            %
            %           - S.w: column vector of frequencies in [rad/s]
            %           - S.S: column vector of spectral density in 
            %             [m^2 rad/ s]
            %           - S.mu (optional): weighting for spectrum in 
            %             multi-spectra sea-states

            WecOptLib.utils.checkSpectrum(spectra)
            obj.spectra = spectra;
            
        end
        
    end
    
end
