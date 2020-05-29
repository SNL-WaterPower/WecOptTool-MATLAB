classdef SeaState < WecOptLib.experimental.base.Data
    
    properties (GetAccess=protected)
        meta = struct("name", {"S",     ...
                               "w"},    ...
                      "validation", {@isnumeric,    ...
                                     @isnumeric});
    end
    
    methods
        
        function obj = SeaState(input)
            
            obj = obj@WecOptLib.experimental.base.Data(input);
            obj.makeMu()
            
        end
        
    end
    
    methods (Access=private)
        
        function makeMu(obj)
            
            if isprop(obj(1), "mu")
                return
            end
            
            Prop = obj(1).addprop("mu");
            NSS = length(obj);

            if NSS == 1

                % Single sea-state requires no weighting
                obj(1).mu = 1;  

            else

                % Equalise weightings for multi-sea-states if not given
                for iSS = 1:NSS
                    obj(iSS).mu = 1;     
                end            

                warn = ['Provided wave spectra have no weightings ' ...
                        '(field mu). Equal weighting presumed.'];
                warning('WaveSpectra:NoWeighting', warn);
                
            end
            
            Prop.SetAccess = "private";

        end
        
    end
    
end

