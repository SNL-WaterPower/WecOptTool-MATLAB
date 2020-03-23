classdef RM3Study < handle
    %RM3STUDY
    
    properties
        
        nemohDir
        spectra
        controlType
        geomMode
        controlParams
        geomLowerBound
        geomUpperBound
        geomX0
        out
        
    end
    
    properties (Access=protected)
        ID
    end
    
    properties (Constant, Access=protected)
        allIDs = WecOptLib.utils.StoreIDs
    end
    
    methods
        
        function obj = RM3Study()
            obj.makeID();
            obj.setNEMOHDir();
        end
        
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
            obj.spectra = spectra;
        end
        
        function copyNEMOH(obj, copyPath)
            
            if ~exist(obj.nemohDir, 'dir')
                return
            end
            
            copyfile(obj.nemohDir, copyPath);
            
        end
        
        function delete(obj)
            % Remove the NEMOH directory if not in parallel
            if isempty(getCurrentTask())
                obj.rmNEMOHDir();
            end
        end
        
    end
    
    methods (Access=protected)
        
        function obj = makeID(obj)
            
            testID = dec2hex(randi(16777216, 1), 6);
            
            if isempty(obj.allIDs.value)
                obj.allIDs.value(end + 1) = testID;
                obj.ID = testID;
                return
            end
            
            while true
                testID = dec2hex(randi(16777216, 1), 6);
                if ~ismember(testID, obj.allIDs.value)
                    obj.allIDs.value(end + 1) = testID;
                    obj.ID = testID;
                    return
                end
            end
            
        end
        
        function obj = setNEMOHDir(obj)
            obj.nemohDir = join([tempdir filesep "NEMOH" obj.ID], "");
        end
        
        function obj = rmNEMOHDir(obj)
            if exist(obj.nemohDir, 'dir')
                rmdir(obj.nemohDir, 's');
            end
        end
        
    end
    
end

