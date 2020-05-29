classdef Performance < WecOptLib.experimental.base.Data
    
    properties (GetAccess=protected)
        meta = struct("name", {"pow"},         ...
                      "validation", {@isnumeric});
    end
    
end