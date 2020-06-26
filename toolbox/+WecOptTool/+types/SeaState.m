classdef SeaState < WecOptTool.base.Data
    % Data type for storage of sea state information.
    %
    % This data type defines a set of parameters that are common to 
    % description of sea-states and is based upon the formats used by
    % the `WAFO MATLAB toolbox <http://www.maths.lth.se/matstat/wafo/>`_.
    %
    % The following parameters must be provided within the input struct 
    % (any additional parameters given will also be stored within the 
    % created object:
    %
    %     * S
    %     * w
    %
    % The following parameters are optional, and if not given will be 
    % given a default upon instantiation of the object:
    %
    %     * mu
    %
    % Once created, the parameters in the object are read only, but the
    % object can be converted to a struct, and then modified.
    %
    % Arguments:
    %    input (struct):
    %        A struct (not array) whose fields represent the parameters
    %        to be stored.
    %
    % Attributes:
    %     S (array of float): Spectral density
    %     w (array of float): angular frequency
    %     mu (float): spectrum weighting (defaults to 1)
    %
    % Methods:
    %    struct(): convert to struct
    %
    % Note:
    %    To create an array of SeaState objects see the
    %    :mat:func:`+WecOptTool.types` function.
    %
    % --
    %
    %  SeaState Properties:
    %     S - Spectral density
    %     w - angular frequency
    %     mu - spectrum weighting (defaults to 1)
    %
    %  SeaState Methods:
    %    struct - convert to struct
    %
    % See also WecOptTool.types
    %
    % --
    
    % Copyright 2020 National Technology & Engineering Solutions of Sandia, 
    % LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
    % U.S. Government retains certain rights in this software.
    %
    % This file is part of WecOptTool.
    % 
    %     WecOptTool is free software: you can redistribute it and/or 
    %     modify it under the terms of the GNU General Public License as 
    %     published by the Free Software Foundation, either version 3 of 
    %     the License, or (at your option) any later version.
    % 
    %     WecOptTool is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %     GNU General Public License for more details.
    % 
    %     You should have received a copy of the GNU General Public 
    %     License along with WecOptTool.  If not, see 
    %     <https://www.gnu.org/licenses/>.
    
    properties
        baseS
        basew
    end
    
    properties (GetAccess=protected)
        meta = struct("name", {"S",     ...
                               "w"},    ...
                      "validation", {@isnumeric,    ...
                                     @isnumeric});
    end
    
    methods
        
        function obj = SeaState(input, varargin)
            
            obj = obj@WecOptTool.base.Data(input);
            
            p = inputParser;
            addParameter(p, 'tailTolerence', -1);
            parse(p, varargin{:});
            
            % Copy original data and then reassign S and w.
            obj.baseS = obj.S;
            obj.basew = obj.w;
            
            if p.Results.tailTolerence > 0
                [obj.S, obj.w] = obj.removeTails(obj.basew,     ...
                                                 obj.baseS,     ...
                                                 p.Results.tailTolerence);
            end
            
        end
        
        function validateArray(obj)
            makeMu(obj)
        end
        
    end
    
    methods (Access=private)
        
        function makeMu(obj)
                        
            if isprop(obj(1), "mu")
                return
            end
            
            NSS = length(obj);

            if NSS > 1
                warn = ['Provided wave spectra have no weightings ' ...
                        '(field mu). Equal weighting presumed.'];
                warning('WaveSpectra:NoWeighting', warn);
            end

            for iSS = 1:NSS
                Prop = obj(iSS).addprop("mu");
                obj(iSS).mu = 1;
                Prop.SetAccess = "private";
            end

        end
        
    end
    
    methods (Static)
        
        function [noTailW, noTailS] = removeTails(w, S, tailTolerence)
            % Removes Spectra less than tol % of max(S)

            % Parameters
            %-----------
            % w: vector
            %    angular frequencies
            % S: vector
            %    Spectral densities
            % tailTolerence: float
            %    Percentage of maximum to include in spectrum
            %
            % Returns
            %--------
            % noTailW : vector
            %    w less tails outside toerance
            % noTailS: vector
            %    S less tails outside toerance

            % Remove tails of the spectra; return indicies of the vals>tol% of max
            specGreaterThanTolerence = find(S > max(S)*tailTolerence);

            iStart = min(specGreaterThanTolerence);
            iEnd   = max(specGreaterThanTolerence);
            iSkip  = 1;
            disp(iStart)
            disp(iEnd)

            mustBeGreaterThanOrEqual(iEnd, iStart)

            noTailW = w(iStart:iSkip:iEnd);
            noTailS = S(iStart:iSkip:iEnd);    

        end

    end

end


