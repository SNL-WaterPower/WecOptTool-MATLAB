classdef RM3DeviceModel < WecOptLib.volatile.DeviceModelTemplate
    
    methods
        
        function [hydro, rundir] = getNemoh(obj, geomMode, geomParams)
            
            [hydro,rundir] = WecOptLib.volatile.RM3_getNemoh(geomMode,  ...
                                                             geomParams);
        end
        
        function forces = getForces(obj, S, hydro, controlType, maxVals)
            
            forces = WecOptLib.volatile.buildRM3(S,             ...
                                                 hydro,         ...
                                                 controlType,   ...
                                                 maxVals);
            
        end
        
    end
    
end


