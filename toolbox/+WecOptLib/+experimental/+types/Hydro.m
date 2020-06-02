classdef Hydro < WecOptLib.experimental.base.Data
    
    properties (GetAccess=protected)
        meta = struct("name", {"Vo",    ...
                               "C",     ...
                               "B",     ...
                               "A",     ...
                               "ex",    ...
                               "ex_ma", ...
                               "ex_ph", ...
                               "ex_re", ...
                               "ex_im"},    ...
                      "validation", {@isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric});
    end
    
end
