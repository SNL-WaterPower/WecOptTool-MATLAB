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
    %    S (struct):
    %        A struct containing the required fields, validated by the
    %        :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum` method.
    %    options: name-value pair options. See below.
    %
    % The following options are supported:
    %
    %    resampleByError (float):
    %        Resample the given spectra such that the error with respect
    %        to the original spectral density is less than the given
    %        percentage of the maximum spectral density (per spectrum).
    %    resampleByStep (float):
    %        Resample the spectra with the given angular frequency step.
    %    trimFrequencies (float):
    %        Remove frequencies with spectral density less than the
    %        given percentage of the maximum (per spectrum).
    %    extendFrequencies (int):
    %        Add addition frequencies such that the largest value is
    %        extendFrequencies times the maximum (i.e. max(w)).
    %
    % Note:
    %    The order of operations (if required) is to trim the frequencies 
    %    first, then resample then, finally, extend the frequencies.
    %
    % Example:
    %    Create an array of SeaState objects, with spectra:
    %
    %      #. trimmed to include all frequencies containing 99% of the max 
    %         spectral density
    %      #. resampled to 5% maximum error in max spectral density
    %      #. extended so that the maximum frequency is 4 times the 
    %         trimmed maximum
    %
    %    >>> S = WecOptLib.tests.data.example8Spectra();
    %    >>> SS = WecOptTool.types("SeaState", S,           ...
    %    ...                       "resampleByError", 0.05, ...
    %    ...                       "trimFrequencies", 0.01, ...
    %    ...                       "extendFrequencies", 4);
    %
    % Note:
    %    To create an array of SeaState objects use the
    %    :mat:func:`+WecOptTool.types` function.
    %
    % Attributes:
    %     S (array of float): spectral density
    %     w (array of float): angular frequency
    %     baseS (array of float): unmodified spectral density
    %     basew (array of float): unmodified angular frequency
    %     dw (float): angular frequency step
    %     sampleError (float): 
    %         maximum sampling error as percentage of max(S) 
    %     trimLoss (float):
    %         error due to range trimming as percentage of max(S) 
    %     mu (float): spectrum weighting, for arrays only  (defaults to 1)
    %
    % Methods:
    %    struct(): convert to struct
    %
    % --
    %
    %  SeaState Properties:
    %     S - spectral density
    %     w - angular frequency
    %     baseS - unmodified spectral density
    %     basew - unmodified angular frequency
    %     dw - angular frequency step
    %     sampleError - maximum sampling error as percentage of max(S) 
    %     trimLoss - error due to range trimming as percentage of max(S) 
    %     mu - spectrum weighting, for arrays only (defaults to 1)
    %
    %  SeaState Methods:
    %    getAllFrequencies - return unique frequencies over all sea-states
    %    getRegularFrequencies - return regularly spaced frequencies
    %                            covering all sea-states
    %    plot - plot spectra with comparison to base spectra, if different
    %    validateArray - object array validation
    %    struct - convert to struct
    %    checkSpectrum - validate a struct array representing spectra
    %    getSpecificEnergy - calculate the specific energy of spectra
    %                        struct array
    %    getMaxAbsoluteDensityError - return the maximum absolute error in
    %                                 spectral density between two spectra
    %                                 struct arrays
    %    getRelativeEnergyError - return the relative error in specific
    %                             energy between two spectra struct arrays
    %    trimFrequencies - removes frequencies below a freshold of spectral
    %                      density from a spectra struct array
    %    extendFrequencies - Add multiples of the maximum frequency to a
    %                        spectra struct array
    %    resampleByError - Resample the given seastate struct based on the 
    %                      error in spectral density normalised by the 
    %                      maximum per spectrum.
    %    resampleByStep - Resample the given seastate struct using a given 
    %                     frequency step
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
    
    properties (SetAccess=private)
        baseS
        basew
        dw
        sampleError
        trimLoss
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
                                         mustBeNonzero}
                options.extendFrequencies {mustBeInteger,   ...
                                           mustBePositive,  ...
                                           mustBeFinite,    ...
                                           mustBeNonzero}
                options.resampleByError {mustBeNumeric,     ...
                                         mustBePositive,    ...
                                         mustBeFinite,      ...
                                         mustBeNonzero}
                options.resampleByStep {mustBeNumeric,      ...
                                        mustBePositive,     ...
                                        mustBeFinite,       ...
                                        mustBeNonzero}
            end
            
            obj = obj@WecOptTool.base.Data(S);
            
            % Copy original data and then reassign S and w.
            obj.basew = obj.w;
            obj.baseS = obj.S;
            obj.dw = obj.w(2) - obj.w(1);
            obj.trimLoss = 0;
            obj.sampleError = 0;
            
            if isfield(options, "resampleByError") && ...
               isfield(options, "resampleByStep")
           
               msg = ['Only one of options "resampleByError" or '    ...
                      '"resampleByStep" may be given'];
               error("WecOptTool:SeaState:BadOptions", msg)
               
            end
                  
            if isfield(options, "trimFrequencies")
                S = obj.trimFrequencies(S, options.trimFrequencies);
                obj.trimLoss = options.trimFrequencies;
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
            
            if isfield(options, "extendFrequencies")
                S = obj.extendFrequencies(S, options.extendFrequencies);
            end
            
            obj.checkSpectrum(S)
            
            obj.w = S.w;
            obj.S = S.S;
            
        end
        
        function allFreqs = getAllFrequencies(obj)
            % Returns all unique frequencies over all sea-states
            %
            % Returns:
            %     array: sorted unique angular frequencies [rad / s]
            
            allFreqs = [];
            
            for i = 1:length(obj)
                allFreqs = cat(1, allFreqs, obj(i).w);
            end
            
            allFreqs = unique(allFreqs);
            
        end
        
        function freqs = getRegularFrequencies(obj, dw)
            % Returns regularly spaced frequencies covering all sea-states
            % at the given step size
            %
            % Arguments:
            %     dw (float): angular frequency step
            %
            % Returns:
            %     array: regular angular frequencies [rad / s]
            
            arguments
                obj
                dw {mustBeNumeric,    ...
                    mustBePositive,   ...
                    mustBeFinite,     ...
                    mustBeNonzero}
            end
            
            allFreqs = obj.getAllFrequencies();
            wMin = min(allFreqs);
            wMax = max(allFreqs);
            
            wIntegerStepMin = floor(wMin / dw) * dw;
            wIntegerStepMax = ceil(wMax / dw) * dw;                                

            freqs = wIntegerStepMin:dw:wIntegerStepMax;
            freqs = freqs';
            
        end
        
        function plot(obj)
            % Plot spectra and comparison to base spectra, if different.
            % 
            % One plot is created per spectrum in the array.
            
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
                
                if obj(i).sampleError > eps
                    
                    plot(wMod, SMod, '-o', 'DisplayName', labelMod)
                    addTitle = sprintf('Max Resampling Error: %.2f%%', ...
                                       obj(i).sampleError * 100);
                    titleChar = [titleChar addTitle];
                    
                end
                
                if obj(i).trimLoss > eps
                                        
                    if titleChar
                        titleChar = [titleChar '; '];
                    end
                    
                    xline(min(wMod), '--',  ...
                          'DisplayName', 'Modified Lower Bound')
                    xline(max(wMod), '-.',  ...
                          'DisplayName', 'Modified Upper Bound')
                                        
                    addTitle = sprintf('Trim Losses: %.2f%%',  ...
                                       obj(i).trimLoss * 100);
                    titleChar = [titleChar addTitle];
                              
                end

                if titleChar, title(titleChar), end
                xlabel('Angular frequency [rad / s]','Interpreter','latex')
                ylabel('Spectral Density [m$^2$ s / rad]',  ...
                       'Interpreter','latex')
                legend()
                grid
                
                hold off; 
                
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
            % (following `WAFO <https://github.com/wafo-project/wafo>`_).
            %
            % Arguments:
            %    S (struct):
            %        struct array with the fields:
            %
            %        * w - column vector of frequencies [rad/s]
            %        * S - column vector of spectral density 
            %          [m\ :sup:`2` s/rad]
            %
            % Note:
            %    This method makes the following checks:
            %
            %      #. The struct has fields S and w
            %      #. Fields S and w are the same length
            %      #. Fields S and w are column vectors
            %      #. Field w is positive
            %      #. Field w is monotonic
            %      #. Field w is regular
            %
            %
            % Example:
            %    Use WAFO to create a Bretschneider spectrum
            %
            %    >>> Hm0 = 5;
            %    >>> Tp = 8;
            %    >>> S = bretschneider([],[Hm0,Tp]);
            %    >>> WecOptLib.utils.checkSpectrum(S)
            %
            
            arguments
                S struct
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
                               'negative values. Frequency values must '...
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
            
            function result = checkStart(S, idx)
                
                try
                    
                    dw = uniquetol(diff(S.w), 1e-9);
                    
                    if length(dw) > 1
                        result = 0;
                        return
                    end
                    
                    result = abs(mod(S.w(1), dw)) < eps;
                    
                    if ~result
                        wID = 'SeaState:checkSpectrum:badStart';
                        msg = ['First frequency not integer multiple '  ...
                               'of frequency step'];
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
            check7 = @(Spect,idx) checkStart(Spect, idx);
            
            pass = pass * sum(arrayfun(check1, S, inds));
            pass = pass * sum(arrayfun(check2, S, inds));
            pass = pass * sum(arrayfun(check3, S, inds));
            pass = pass * sum(arrayfun(check4, S, inds));
            pass = pass * sum(arrayfun(check5, S, inds));
            pass = pass * sum(arrayfun(check6, S, inds));
            pass = pass * sum(arrayfun(check7, S, inds));
            
            if ~pass
                msg = ['Given spectrum is incorrectly defined. See '    ...
                       'warnings for details.'];
                error("WecOptTool:SeaState:checkSpectrum", msg)
            end
            
        end
        
        function energies = getSpecificEnergy(S, options)
            % Calculates the specific energy of the given spectra struct 
            % array
            %
            % Arguments:
            %    S (struct):
            %        struct array that satifies the
            %        :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum` 
            %        method
            %    options: name-value pair options. See below.
            %
            % The following options are supported:
            %
            %    g (optional, float):
            %        Acceleration due to gravity, default = 9.81 
            %        m/s\ :sup:`2`.
            %    rho (optional, float):
            %        Water density, default 1028 kg/m\ :sup:`3`.
            %
            % Returns:
            %     array: specify energy per spectra [J / m\ :sup:`2`]
            
            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)}
                options.g {mustBeNumeric} = 9.81
                options.rho {mustBeNumeric, mustBePositive} = 1028
            end
            
            N = length(S);
            energies = zeros(1, N);
            
            for i = 1:N
                energies(i) = options.g * options.rho *     ...
                                                trapz(S(i).w, S(i).S);
            end
            
        end
        
        function errors = getMaxAbsoluteDensityError(trueS, approxS)
            % Returns the maximum absolute error in spectral density 
            % between two spectra struct arrays.
            %
            % Arguments:
            %    trueS (struct):
            %        struct array representing the true value and satifies
            %        :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum` 
            %    approxS (struct):
            %        struct array representing the approximate value and 
            %        satifies 
            %        :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum`
            %
            % Returns:
            %     array: absolute error per spectrum [m\ :sup:`2` s/rad]
            
            arguments
                trueS {WecOptTool.types.SeaState.checkSpectrum(trueS)}
                approxS                                                 ...
                  {WecOptTool.types.SeaState.checkSpectrum(approxS),    ...
                   WecOptLib.validation.mustBeEqualLength(trueS,        ...
                                                          approxS)}
            end
            
            import WecOptTool.types.SeaState
            
            N = length(trueS);
            errors = zeros(1, N);
            
            for i = 1:N
                
                interpS = interp1(approxS(i).w,   ...
                                  approxS(i).S,   ...
                                  trueS(i).w,       ...
                                  'linear',         ...
                                  'extrap');
                
                absoluteDensityError = abs(interpS - trueS(i).S);
                errors(i) = max(absoluteDensityError);
                
            end
            
        end
                
        function errors = getRelativeEnergyError(trueS, approxS)
            % Returns the relative error in specific energy between two 
            % spectra struct arrays
            %
            % Arguments:
            %    trueS (struct):
            %        struct array representing the true value and satifies
            %        :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum` 
            %    approxS (struct):
            %        struct array representing the approximate value and 
            %        satifies 
            %        :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum`
            %
            % Returns:
            %     array: relative error per spectrum
            
            arguments
                trueS {WecOptTool.types.SeaState.checkSpectrum(trueS)}
                approxS                                                 ...
                  {WecOptTool.types.SeaState.checkSpectrum(approxS),    ...
                   WecOptLib.validation.mustBeEqualLength(trueS,        ...
                                                          approxS)}
            end
            
            import WecOptTool.types.SeaState
            
            for i = 1:length(trueS)
                
                interpS(i).w = trueS(i).w;
                interpS(i).S = interp1(approxS(i).w, ...
                                       approxS(i).S, ...
                                       trueS(i).w,     ...
                                       'linear',       ...
                                       'extrap');
                                   
            end
                  
            baseEnergy = SeaState.getSpecificEnergy(trueS);
            interpEnergy = SeaState.getSpecificEnergy(interpS);

            errors = abs(interpEnergy ./ baseEnergy - 1);
            
        end

        function S = trimFrequencies(S, densityTolerence)
            % Removes frequencies below a freshold of the maximum spectral 
            % density, per spectra, of a spectra struct array.
            %
            % Arguments:
            %     S (struct):
            %         struct array that satifies the
            %         :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum` 
            %         method
            %     densityTolerence (float):
            %         Percentage of maximum spectral density
            %
            % Returns:
            %     struct: Sea-state struct which conforms to 
            %     :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum`
            %
            % Example:
            %     Remove frequencies containing less than 1% of the maximum
            %     spectral density
            %
            %     >>> import WecOptTool.types.SeaState
            %     >>> S = WecOptLib.tests.data.example8Spectra();
            %     >>> newS = SeaState.trimFrequencies(S, 0.01);
            %     
            
            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)}
                densityTolerence {mustBeNumeric,    ...
                                  mustBePositive,   ...
                                  mustBeFinite,     ...
                                  mustBeNonzero}
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
            % Adds multiples of the maximum frequency to a spectra struct 
            % array
            %
            % Arguments:
            %     S (struct):
            %         struct array that satifies the
            %         :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum` 
            %         method
            %     nRepeats (int):
            %         Number of repetitions of max frequency
            %
            % Returns:
            %     struct: Sea-state struct which conforms to 
            %     :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum`
            %
            % Example:
            %     Double the frequency range of the given spectrum
            %
            %     >>> import WecOptTool.types.SeaState
            %     >>> S = WecOptLib.tests.data.exampleSpectrum();
            %     >>> disp(max(S.w))
            %         3.2000
            %     <BLANKLINE>
            %     >>> Snew = SeaState.extendFrequencies(S, 2);
            %     >>> disp(max(Snew.w))
            %         6.4000
            %
            
            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)}
                nRepeats {mustBeInteger,    ...
                          mustBePositive,   ...
                          mustBeFinite,     ...
                          mustBeNonzero}
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
            % Resample the given seastate struct based on the error in
            % spectral density normalised by the maximum per spectrum.
            % a maximum error of the maximum spectral density for a spectra
            % struct array.
            %
            % Arguments:
            %     S (struct):
            %         struct array that satifies the
            %         :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum` 
            %         method
            %     targetError (float):
            %         Target maximum error in normalised spectral density 
            %     min_dw (optional, float):
            %         Smallest frequency step to test, default = 1e-4
            %
            % Returns:
            %      :
            %     - S (struct): Sea-state struct which conforms to 
            %       :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum`
            %     - dw (array): Frequency spacings per spectrum
            
            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)}
                targetError {mustBeNumeric,    ...
                             mustBePositive,   ...
                             mustBeFinite,     ...
                             mustBeNonzero}
                min_dw  {mustBeNumeric,    ...
                         mustBePositive,   ...
                         mustBeFinite,     ...
                         mustBeNonzero} = 1e-4
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
            % Resample the given seastate struct using a given frequency 
            % step
            %
            % Arguments:
            %     S (struct):
            %         struct array that satifies the
            %         :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum` 
            %         method
            %     dw (float):
            %         Angular frequency step size
            %
            % Returns:
            %      :
            %     - S (struct): Sea-state struct which conforms to 
            %       :mat:meth:`+WecOptTool.+types.SeaState.checkSpectrum`
            %     - errors (array): error in spectral density (normalised 
            %       by the maximum) per spectrum
            %
            
            arguments
                S {WecOptTool.types.SeaState.checkSpectrum(S)}
                dw {mustBeNumeric,  ...
                    mustBePositive, ...
                    mustBeFinite,   ...
                    mustBeNonzero}
            end
            
            import WecOptTool.types.SeaState
            
            N = length(S);
            baseS = S;
            
            for i = 1:N
                
                wMin = min(S(i).w);
                wMax = max(S(i).w);
                
                % Ensure w is at integer intervals of the step
                wIntegerStepMin = floor(wMin / dw) * dw;
                wIntegerStepMax = ceil(wMax / dw) * dw;
                wResampled = wIntegerStepMin:dw:wIntegerStepMax;
                wResampled = wResampled';
                
                SResampled = interp1(S(i).w,        ...
                                     S(i).S,        ...
                                     wResampled,    ...
                                     'linear',      ...
                                     'extrap');
                
                S(i).w = wResampled;
                S(i).S = SResampled;
                
            end
            
            abserrors = SeaState.getMaxAbsoluteDensityError(baseS, S);
            errors = abserrors ./ max([baseS.S]);
            
        end
        
    end

end

