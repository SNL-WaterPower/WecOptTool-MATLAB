classdef Motion < WecOptLib.experimental.base.Data
    
    properties (GetAccess=protected)
        meta = struct("name", {"w", "Zi", "F0"},         ...
                      "validation", {@isnumeric, @isnumeric, @isnumeric});
    end
    
end
