classdef Performance < WecOptLib.experimental.base.Data
    
    properties
        pow
    end
    
    properties (GetAccess=protected)
        meta = struct("name", {"powPerFreq"},         ...
                      "validation", {@isnumeric});
    end
    
    methods

        function pow = get.pow(obj)
            pow = sum(obj.powPerFreq);
        end
        
    end
    
end