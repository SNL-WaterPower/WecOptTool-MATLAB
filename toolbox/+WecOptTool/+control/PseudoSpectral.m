classdef PseudoSpectral < WecOptTool.control.AbsControl
    
    properties
        controlType = 'PS'
        controlParams
    end
    
    methods
    
        function obj = PseudoSpectral(deltaZmax, deltaFmax)
             
            obj = obj@WecOptTool.control.AbsControl();
            
            if nargin == 1
                msg = ['Arguments deltaZmax, deltaFmax must be ' ...
                       'provided together'];
                error(msg);
            elseif nargin == 2
                obj.controlParams = [deltaZmax, deltaFmax];
            end
        
        end
    
    end

end
