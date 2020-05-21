classdef ExistingNEMOH < WecOptLib.experimental.blocks.Geometry
    
    methods
        
        function hydro = getHydro(obj, nemohFolder)
            
            hydro = struct();
            hydro = WecOptLib.vendor.WEC_Sim.Read_NEMOH(hydro,          ...
                                                        nemohFolder);
           
        end
        
    end
    
end

