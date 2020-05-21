classdef RM3 < WecOptLib.experimental.blocks.Blueprint
    
    properties
        
        Geometries = struct(                                            ...
            'existing',                                                 ...
                WecOptLib.experimental.blocks.geometry.ExistingNEMOH,   ...
            'scalar', Scalar)
        
        Model = Model
        
        Controllers = struct('CC', ComplexCongugate,    ...
                             'P', Damping)
        
    end
    
end
