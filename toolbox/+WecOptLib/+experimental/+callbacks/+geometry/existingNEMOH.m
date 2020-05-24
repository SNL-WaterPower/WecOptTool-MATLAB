function hydro = existingNEMOH(nemohFolder)
            
    hydro = struct();
    hydro = WecOptLib.vendor.WEC_Sim.Read_NEMOH(hydro,          ...
                                                nemohFolder);
           
end
