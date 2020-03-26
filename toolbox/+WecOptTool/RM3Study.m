
% Copyright 2020 Sandia National Labs
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
%     along with Foobar.  If not, see <https://www.gnu.org/licenses/>.

classdef RM3Study < handle
    %RM3STUDY
    
    properties
        
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
            obj.controlType = controlObj.controlType;
            obj.controlParams = controlObj.controlParams;
        end
        
        function obj = addGeometry(obj, geomObj)
            obj.geomMode = geomObj.geomMode;
            obj.geomLowerBound = geomObj.geomLowerBound;
            obj.geomUpperBound = geomObj.geomUpperBound;
            obj.geomX0 = geomObj.geomX0;
        end
        
        function obj = addSpectra(obj, spectra)
            WecOptLib.utils.checkSpectrum(spectra)
            obj.spectra = spectra;
        end
        
        
    end
    
end
