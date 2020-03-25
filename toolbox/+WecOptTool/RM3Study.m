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
