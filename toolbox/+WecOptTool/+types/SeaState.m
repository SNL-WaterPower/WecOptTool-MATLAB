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
    % The values of S and w will be validated by the checkSpectrum method 
    % of this class. The following parameters are optional, and if not 
    % given will be given a default upon instantiation of the object:
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
        dw
        trimLoss
        sampleError
    end
    
    properties (GetAccess=protected)
        meta = struct("name", {"S",     ...
                               "w"},    ...
                      "validation", {@isnumeric,    ...
                                     @isnumeric});
    end
    
    methods
        
        function obj = SeaState(S, options)
            
            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)};
                options.trimFrequencies {mustBeNumeric,     ...
                                         mustBePositive,    ...
                                         mustBeFinite,      ...
                                         mustBeNonzero};
                options.extendFrequencies {mustBeInteger,   ...
                                           mustBePositive,  ...
                                           mustBeFinite,    ...
                                           mustBeNonzero};
                options.resampleByError {mustBeNumeric,     ...
                                         mustBePositive,    ...
                                         mustBeFinite,      ...
                                         mustBeNonzero};
                options.resampleByStep {mustBeNumeric,      ...
                                        mustBePositive,     ...
                                        mustBeFinite,       ...
                                        mustBeNonzero};
            end
            
            obj = obj@WecOptTool.base.Data(S);
            
            % Copy original data and then reassign S and w.
            obj.basew = obj.w;
            obj.baseS = obj.S;
            obj.dw = obj.w(2) - obj.w(1);
            obj.trimLoss = 0;
            obj.sampleError = 0;
            
            if isfield(options, "trimFrequencies")
                S = obj.trimFrequencies(S, options.trimFrequencies);
                obj.trimLoss = options.trimFrequencies;
            end
            
            if isfield(options, "extendFrequencies")
                S = obj.extendFrequencies(S, options.extendFrequencies);
            end
            
            if isfield(options, "resampleByError") && ...
               isfield(options, "resampleByStep")
           
               msg = ['Only one of options "resampleByError" or '    ...
                      '"resampleByStep" may be given'];
               error("WecOptTool:SeaState:BadOptions", msg)
               
            end
                  
            if isfield(options, "resampleByError")
                [S, obj.dw] = obj.resampleByError(S,    ...
                                                  options.resampleByError);
                obj.sampleError = options.resampleByError;
            end
            
            if isfield(options, "resampleByStep")
                [S, err] = obj.resampleByStep(S, options.resampleByStep);
                obj.dw = options.resampleByStep;
                obj.sampleError = err;
            end
            
            obj.w = S.w;
            obj.S = S.S;
            
        end
        
        function allFreqs = getAllFrequencies(obj)
            
            allFreqs = [];
            
            for i = 1:length(obj)
                allFreqs = cat(1, allFreqs, obj(i).w);
            end
            
            allFreqs = unique(allFreqs);
            
        end
        
        function freqs = getRegularFrequencies(obj, dw)
            
            allFreqs = obj.getAllFrequencies();
            wMin = min(allFreqs);
            wMax = max(allFreqs);
            
            wIntegerStepMin = floor(wMin / dw) * dw;
            wIntegerStepMax = ceil(wMax / dw) * dw;                                

            freqs = wIntegerStepMin:dw:wIntegerStepMax;
            freqs = freqs';
            
        end
        
        function validateArray(obj)
            makeMu(obj)
        end
        
        function plot(obj)
            
            h =  findobj('type', 'figure');
            nfigs = length(h);
            
            for i=1:length(obj)
                
                figure(nfigs + i)
                hold on;

                wOrig = obj(i).basew;
                SOrig = obj(i).baseS;
                wMod = obj(i).w;
                SMod = obj(i).S;
                titleChar = '';

                labelOrig = sprintf('Original (Samples=%d)',    ...
                                    length(wOrig));
                labelMod = sprintf('Modified (Samples=%d)', length(wMod));

                plot(wOrig, SOrig, 'DisplayName', labelOrig)
                
                if obj(i).trimLoss > eps
                    
                    xline(min(wMod), '--',  ...
                          'DisplayName', 'Modified Lower Bound')
                    xline(max(wMod), '-.',  ...
                          'DisplayName', 'Modified Upper Bound')
                                        
                    addTitle = sprintf('Trim Losses: %.2f%%',  ...
                                       obj(i).trimLoss * 100);
                    titleChar = [titleChar addTitle];
                              
                end
                
                if obj(i).sampleError > eps
                    
                    if titleChar
                        titleChar = [titleChar '; '];
                    end
                    
                    plot(wMod, SMod, '-o', 'DisplayName', labelMod)
                    addTitle = sprintf('Resampling Error: %.2f%%',  ...
                                       obj(i).sampleError * 100);
                    titleChar = [titleChar addTitle];
                    
                end

                if titleChar, title(titleChar), end
                xlabel('Frequency [$\omega$]','Interpreter','latex')
                ylabel('Spectral Density','Interpreter','latex')
                legend()
                grid
                
                hold off; 
                
            end
                        
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
            
            arguments
                S struct;
            end
            
            function result = checkFields(S, idx)
                fns = {'S','w'};
                wID = 'SeaState:checkSpectrum:missingFields';
                msg = ['Spectrum #%i in array does not contain '        ...
                       'required S.S and S.w fields'];
                result = all(isfield(S, fns));
                if ~result
                    warning(wID, msg, idx)
                end
            end
        
            function result = checkLengths(S, idx)
                try
                    result = length(S.S) == length(S.w);
                    if ~result
                        wID = 'SeaState:checkSpectrum:mismatchedLengths';
                        msg = ['Spectrum #%i in array S.S and S.w ' ...
                               'fields are not same length'];
                        warning(wID, msg, idx)
                    end
                catch
                    result = 0;
                end
            end

            function result = checkCol(S, idx)
                try
                    result = iscolumn(S.S) && iscolumn(S.w);
                    if ~result
                        wID = 'SeaState:checkSpectrum:notColumnVectors';
                        msg = ['Spectrum #%i in array S.S and S.w ' ...
                               'fields are not column vectors'];
                        warning(wID, msg, idx)
                    end
                catch
                    result = 0;
                end
            end

            function result = checkPositive(S, idx)
                try
                    result = all(S.w >=0);
                    if ~result 
                        wID = 'SeaState:checkSpectrum:negativeFrequencies';
                        msg = ['Frequency in Spectrum #%i contains '    ...
                               'negative values. Frequency values must' ...
                               'be positive'];
                        warning(wID, msg, idx)
                    end
                catch
                    result = 0;
                end
            end
            
            function result = checkMonotonic(S, idx)
                try
                    result = all(diff(S.w) >= 0);
                    if ~result
                        wID = 'SeaState:checkSpectrum:notMonotonic';
                        msg = 'Frequency in Spectrum #%i is not monotonic';
                        warning(wID, msg, idx)
                    end
                catch
                    result = 0;
                end
            end
            
            function result = checkRegular(S, idx)
                try
                    result = length(uniquetol(diff(S.w), 1e-9)) == 1;
                    if ~result
                        wID = 'SeaState:checkSpectrum:notRegular';
                        msg = 'Frequency in Spectrum #%i is not regular';
                        warning(wID, msg, idx)
                    end
                catch
                    result = 0;
                end
            end
            
            inds = 1:length(S);
            pass = 1;
            
            check1 = @(Spect,idx) checkFields(Spect, idx);
            check2 = @(Spect,idx) checkLengths(Spect, idx);
            check3 = @(Spect,idx) checkCol(Spect, idx);
            check4 = @(Spect,idx) checkPositive(Spect, idx);
            check5 = @(Spect,idx) checkMonotonic(Spect, idx);
            check6 = @(Spect,idx) checkRegular(Spect, idx);
            
            pass = pass * sum(arrayfun(check1, S, inds));
            pass = pass * sum(arrayfun(check2, S, inds));
            pass = pass * sum(arrayfun(check3, S, inds));
            pass = pass * sum(arrayfun(check4, S, inds));
            pass = pass * sum(arrayfun(check5, S, inds));
            pass = pass * sum(arrayfun(check6, S, inds));
            
            if ~pass
                msg = ['Given spectrum is incorrectly defined. See '    ...
                       'warnings for details.'];
                error("WecOptTool:SeaState:checkSpectrum", msg)
            end
            
        end
                
        function dw = getMeanFreqStep(S)
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
                
        function errors = getSampleError(baseS, S)
            
            arguments
                baseS {WecOptTool.types.SeaState.checkSpectrum(baseS)};
                S {WecOptTool.types.SeaState.checkSpectrum(S),  ...
                   WecOptLib.validation.mustBeEqualLength(baseS, S)};
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
                                                    'extrap');
                
                errors(i) = sum(abs(SNoExtrapOrigInterpolated - ...
                                                SOrig)) / length(SOrig);
                
            end
            
        end

        function S = trimFrequencies(S, densityTolerence)
            % Removes spectra with less than densityTolerence % of max(S)

            % Parameters
            %-----------
            % S: struct
            %    Sea state struct which conforms to checkSpectrum
            % densityTolerence: float
            %    Percentage of maximum to remove from spectrum
            %
            % Returns
            %--------
            % S: struct
            %    Sea state struct which conforms to checkSpectrum
            
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
        
        function  S = extendFrequencies(S, nRepeats)
            
            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)};
                nRepeats {mustBeInteger,    ...
                          mustBePositive,   ...
                          mustBeFinite,     ...
                          mustBeNonzero};
            end
            
            for i = 1:length(S)
                dw = S(i).w(2) - S(i).w(1);
                startw = S(i).w(end) + dw;
                endw = S(i).w(end) * nRepeats;
                extendw = startw:dw:endw;
                S(i).w = [S(i).w; extendw'];
                S(i).S = [S(i).S; extendw' * 0.];
            end
            
        end
        
        function [S, dw] = resampleByError(S,           ...
                                           targetError, ...
                                           min_dw)
            
            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)};
                targetError {mustBeNumeric,    ...
                             mustBePositive,   ...
                             mustBeFinite,     ...
                             mustBeNonzero};
                min_dw  {mustBeNumeric,    ...
                         mustBePositive,   ...
                         mustBeFinite,     ...
                         mustBeNonzero} = 1e-4;
            end
            
            import WecOptTool.types.SeaState
            oldS = [S.S];
            
            function residual = ObjFun(dw) 
                [~, errors] = SeaState.resampleByStep(S, dw);
                residual = max(errors) - targetError;
            end
            
            assert(isequaln(oldS,[S.S]))
            
            w = [S.w];
            dw = WecOptLib.utils.bisection(@ObjFun, min_dw, max(w(:)));
            [S, errors] = SeaState.resampleByStep(S, dw);
            
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
                
                % This approach allows zero error at matching 
                % discretisation
                wRange = wMax - wMin;
                wIntegerStepMax = wMin + ceil(wRange / dw) * dw;
                
                % This approach generates errors at matching discretisation
                % as samples are shifted
                wResampled = wMin:dw:wIntegerStepMax;
                wResampled = wResampled';

                SResampled = interp1(S(i).w,        ...
                                     S(i).S,        ...
                                     wResampled,    ...
                                     'linear',      ...
                                     'extrap');      

                S(i).w = wResampled;
                S(i).S = SResampled;
                
            end
            
            errors = SeaState.getSampleError(baseS, S);
            
        end
        
    end

end


