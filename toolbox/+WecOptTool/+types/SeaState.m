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
        
        function checkSpectrum(S)
            % Checks whether the input S is a valid spectrum structure 
            % (following WAFO).
            %
            % Inputs
            %   S           spectrum structure (can be arrary) in the 
            %               style of WAFO with the fields:
            %
            %       S.w     column vector of frequencies in [rad/s]
            %       S.S     column vector of spectral density in 
            %               [m^2 rad/ s]
            %
            % Example
            %   Hm0 = 5;
            %   Tp = 8;
            %   S = bretschneider([],[Hm0,Tp]);
            %   WecOptLib.utils.checkSpectrum(S)
            %

            rootError = 'SeaState:checkSpectrum:';
            
            function [] = checkFields(S, idx)
                fns = {'S','w'};
                msg = ['Spectrum #%i in array does not contain '        ...
                       'required S.S and S.w fields'];
                ID = [rootError 'missingFields'];
                try
                    assert(all(isfield(S, fns)), ID, msg, idx)
                catch ME
                    throw(ME)
                end
            end

            function [] = checkLengths(S, idx)
                msg = ['Spectrum #%i in array S.S and S.w fields are '  ...
                       'not same length'];
                ID = [rootError 'mismatchedLengths'];
                try
                    assert(length(S.S) == length(S.w), ID, msg, idx)
                catch ME
                    throw(ME)
                end
            end

            function [] = checkCol(S, idx)
                msg = ['Spectrum #%i in array S.S and S.w fields are '  ...
                       'not column vectors'];
                ID = [rootError 'notColumnVectors'];
                try
                    assert(iscolumn(S.S) && iscolumn(S.w), ID, msg, idx)
                catch ME
                    throw(ME)
                end
            end

            function [] = checkPositive(S, idx)
                msg = ['Frequency in Spectrum #%i contains negative '   ...
                       'values. Frequency values must be positive'];
                ID = [rootError 'negativeFrequencies'];
                try
                    assert(all(S.w >=0), ID, msg, idx)
                catch ME
                    throw(ME)
                end
            end
            
            inds = 1:length(S);

            try
                arrayfun(@(Spect,idx) checkFields(Spect, idx), S, inds);
                arrayfun(@(Spect,idx) checkLengths(Spect, idx), S, inds);
                arrayfun(@(Spect,idx) checkCol(Spect, idx), S, inds);
                arrayfun(@(Spect,idx) checkPositive(Spect, idx), S, inds);
            catch MEs
                throw(MEs)
            end
            
        end

        function S = trimFrequencies(S, densityTolerence)
            % Removes Spectra less than densityTolerence % of max(S)

            % Parameters
            %-----------
            % w: vector
            %    angular frequencies
            % S: vector
            %    Spectral densities
            % densityTolerence: float
            %    Percentage of maximum to include in spectrum
            %
            % Returns
            %--------
            % wNew : vector
            %    w less tails outside toerance
            % SNew: vector
            %    S less tails outside toerance

            % Remove tails of the spectra; return indicies of the 
            % vals > tol% of max
            
            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)};
                densityTolerence {mustBeNumeric,    ...
                                  mustBePositive,   ...
                                  mustBeFinite,     ...
                                  mustBeNonzero};
            end
            
            
            
            for k = 1:length(S)
                i = find(S(k).S > max(S(k).S) * densityTolerence);
                iStart = min(i);
                iEnd = max(i);
                S(k).w = S(k).w(iStart:iEnd);
                S(k).S = S(k).S(iStart:iEnd);
            end
            
        end
        
        function  S = extendFrequencies(S, nMaxFreq)
            
            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)};
                nMaxFreq {mustBeInteger,    ...
                          mustBePositive,   ...
                          mustBeFinite,     ...
                          mustBeNonzero};
            end
            
            for i = 1:length(S)
                endW = S(i).w(end, :) * nMaxFreq;
                S(i).w(end+1) = endW(i);
                S(i).S(end+1) = 0;
            end
            
        end
        
        function [S, dw] = resampleByError(S,           ...
                                           maxError,    ... 
                                           dw,          ...
                                           reductionFactor)
            
            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)};
                maxError {mustBeNumeric,    ...
                          mustBePositive,   ...
                          mustBeFinite,     ...
                          mustBeNonzero};
                dw {mustBeNumeric,   ...
                    mustBePositive,  ...
                    mustBeFinite,    ...
                    mustBeNonzero} = ...
                                max(WecOptTool.types.SeaState.meanDw(S));
                reductionFactor {mustBeNumeric,    ...
                                 mustBePositive,   ...
                                 mustBeFinite,     ...
                                 mustBeNonzero} = 0.05;
            end
            
            import WecOptTool.types.SeaState
            
            while true
                
                dw = dw * (1 - reductionFactor);
                [postS, errors] = SeaState.resampleByStep(S, dw);
                
                if max(errors) < maxError
                    S = postS;
                    break
                end
                
            end
            
        end
        
        function [S, errors] = resampleByStep(S, dw)
            
            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)};
                dw {mustBeNumeric,  ...
                    mustBePositive, ...
                    mustBeFinite,   ...
                    mustBeNonzero};
            end
            
            import WecOptTool.types.SeaState
            
            N = length(S);
            baseS = S;
            
            for i = 1:N
                
                wMin = min(S(i).w);
                wMax = max(S(i).w);
                
                wIntegerStepMin = floor(wMin / dw) * dw;
                wIntegerStepMax = ceil(wMax / dw) * dw;                    

                wResampled = wIntegerStepMin:dw:wIntegerStepMax;
                wResampled = wResampled';

                WecOptLib.errorCheck.checkMinMaxStepRange(  ...
                                min(wResampled), max(wResampled), dw)

                SResampled = interp1(S(i).w,        ...
                                     S(i).S,        ...
                                     wResampled,    ...
                                     'linear',      ...
                                     0);      

                S(i).w = wResampled;
                S(i).S = SResampled;
                
            end
            
            errors = SeaState.sampleError(baseS, S);
            
        end
        
        function errors = sampleError(baseS, S)
            
            arguments
                baseS {WecOptTool.types.SeaState.checkSpectrum(baseS)};
                S {WecOptTool.types.SeaState.checkSpectrum(S),  ...
                   mustBeEqualLengthSpectra(baseS, S)};
            end
            
            N = length(baseS);
            errors = zeros(1, N);
            
            for i = 1:N
                
                wOrig = baseS(i).w;
                SOrig = baseS(i).S;
                wResampled = S(i).w;
                SResampled = S(i).S;
                
                SNoExtrapOrigInterpolated = interp1(wResampled, ...
                                                    SResampled, ...
                                                    wOrig,      ...
                                                    'linear',   ...
                                                    0);
                
                errorNoExtrap = WecOptLib.utils.MAAPError(  ...
                                        SOrig, SNoExtrapOrigInterpolated);
                errors(i) = errorNoExtrap;
                
            end
            
        end
        
        function dw = meanDw(S)
            % Returns the mean of the frequency discrtization 
            %
            % Parameters
            % ----------
            % S: struct
            %     seastate must have S.w and S.S
            %
            % Returns
            % -------
            % dw: array
            %     mean difference

            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)};
            end
            
            dw = zeros(1, length(S));
            
            for i = 1:length(S)    
                dw(i) = mean(diff(S(i).w));
            end
        end

    end

end

function mustBeEqualLengthSpectra(baseS, S)
    msg = 'Spectra must be of equal length';
    ID = 'WecOptTool:assertEqualLengthSpectra:incorrectLength';
    assert(length(baseS) == length(S), ID, msg);
end