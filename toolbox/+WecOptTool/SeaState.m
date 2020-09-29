classdef SeaState
    % Data type for storage of sea state information.
    %
    % This data type defines a set of parameters that are common to 
    % description of sea states and is based upon the formats used by
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
    %     * note
    %
    % Arguments:
    %    S (struct):
    %        A struct containing the required fields, validated by the
    %        :mat:meth:`+WecOptTool.SeaState.checkSpectrum` method.
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
    %    >>> S = WecOptTool.SeaState.example8Spectra("resampleByError", 0.05, ...
    %    ...                                         "trimFrequencies", 0.01, ...
    %    ...                                         "extendFrequencies", 4);
    %
    %
    % Attributes:
    %     S (array of float): spectral density [m\ :sup:`2` s/rad]
    %     w (array of float): angular frequency [rad / s]
    %     baseS (array of float):
    %         unmodified spectral density [m\ :sup:`2` s/rad]
    %     basew (array of float): unmodified angular frequency [rad / s]
    %     dw (float): angular frequency step [rad / s]
    %     sampleError (float): 
    %         maximum sampling error as percentage of max(S) 
    %     trimLoss (float):
    %         error due to range trimming as percentage of max(S)
    %     specificEnergy (float):
    %         the specific energy of the spectra [J / m\ :sup:`2`]
    %     mu (float): spectrum weighting, for arrays only  (defaults to 1)
    %     note (string): a description of the spectrum
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
    %     specificEnergy - the specific energy of the spectra
    %     mu - spectrum weighting, for arrays only (defaults to 1)
    %     note - a description of the spectrum
    %
    %  SeaState Methods:
    %    getAllFrequencies - return unique frequencies over all sea states
    %    getRegularFrequencies - return regularly spaced frequencies
    %                            covering all sea states
    %    getAmplitudeSpectrum - return wave amplitude per angular frequency
    %    plot - plot spectra with comparison to base spectra, if different
    %    validateArray - object array validation
    %    checkSpectrum - validate a struct array representing spectra
    %    getSpecificEnergy - calculate the specific energy of spectra
    %                        struct array
    %    getMaxAbsoluteDensityError - return the maximum absolute error in
    %                                 spectral density between two spectra
    %                                 struct arrays
    %    getRelativeEnergyError - return the relative error in specific
    %                             energy between two spectra struct arrays
    %    trimFrequencies - removes frequencies below a threshold of 
    %                      spectral density from a spectra struct array
    %    extendFrequencies - Add multiples of the maximum frequency to a
    %                        spectra struct array
    %    resampleByError - Resample the given seastate struct based on the 
    %                      error in spectral density normalized by the 
    %                      maximum per spectrum.
    %    resampleByStep - Resample the given seastate struct using a given 
    %                     frequency step
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
        S
        w
        mu
        note
        baseS
        basew
        dw
        sampleError
        trimLoss
        specificEnergy
    end
    
    methods
        
        function obj = SeaState(S, options)
            
            arguments
                S = [];
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
            
            if isempty(S)
                return
            else
                obj.checkSpectrum(S);
            end
                        
            for i = 1:length(S)
                
                obj(i).basew = S(i).w;
                obj(i).baseS = S(i).S;
                obj(i).dw = S(i).w(2) - S(i).w(1);
                obj(i).trimLoss = 0;
                obj(i).sampleError = 0;

                if isfield(S, "mu")
                    obj(i).mu = S(i).mu;
                end
                
                if isfield(S, "note")
                    obj(i).note = S(i).note;
                else
                    obj(i).note = sprintf('Spectrum %d', i);
                end

                if isfield(options, "resampleByError") && ...
                   isfield(options, "resampleByStep")

                   msg = ['Only one of options "resampleByError" or '    ...
                          '"resampleByStep" may be given'];
                   error("WecOptTool:SeaState:BadOptions", msg)

                end
                
                if isfield(options, "trimFrequencies")
                    S = obj.trimFrequencies(S, options.trimFrequencies);
                    obj(i).trimLoss = options.trimFrequencies;
                end
                
                if isfield(options, "resampleByError")
                    [S, obj(i).dw] = obj.resampleByError(S,    ...
                                                  options.resampleByError);
                    obj(i).sampleError = options.resampleByError;
                end

                if isfield(options, "resampleByStep")
                    [S, err] = obj.resampleByStep(S,   ...
                                                  options.resampleByStep);
                    obj(i).dw = options.resampleByStep;
                    obj(i).sampleError = err;
                end

                if isfield(options, "extendFrequencies")
                    S = obj.extendFrequencies(S,   ...
                                              options.extendFrequencies);
                end

                obj.checkSpectrum(S)

                obj(i).w = S(i).w;
                obj(i).S = S(i).S;
                obj(i).specificEnergy = obj.getSpecificEnergy(S);
                
            end
            
            obj = obj.makeMu(obj);
            
        end
        
        function allFreqs = getAllFrequencies(obj)
            % Returns all unique frequencies over all sea states
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
            % Returns regularly spaced frequencies covering all sea states
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
            
            wIntegerStepMin = min([floor(wMin / dw),1]) * dw;
            wIntegerStepMax = ceil(wMax / dw) * dw;                                

            freqs = wIntegerStepMin:dw:wIntegerStepMax;
            freqs = freqs';
            
        end
        
        function Aw = getAmplitudeSpectrum(obj)
            % Get wave amplitude per angular frequency
            %
            % Returns:
            %     array: wave amplitudes [m]
            
            Aw = sqrt(2 * obj.dw * obj.S(:));
            
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
                        
    end
    
    methods (Static, Access=private)
        
        function obj = makeMu(obj)
                        
            if ~isempty(obj(1).mu)
                return
            end
            
            NSS = length(obj);

            if NSS > 1
                warn = ['Provided wave spectra have no weightings ' ...
                        '(field mu). Equal weighting presumed.'];
                warning('WaveSpectra:NoWeighting', warn);
            end

            for iSS = 1:NSS
                obj(iSS).mu = 1;
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
            %      #. The first entry of field w is an integer multiple of 
            %         the frequency step
            %
            %
            % Example:
            %    Use WAFO to create a Bretschneider spectrum
            %
            %    >>> Hm0 = 5;
            %    >>> Tp = 8;
            %    >>> S = bretschneider([],[Hm0,Tp]);
            %    >>> WecOptTool.utils.checkSpectrum(S)
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
                    result = length(uniquetol(diff(S.w),    ...
                                    eps('single'))) == 1;
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
                    
                    dw = uniquetol(diff(S.w), eps('single'));
                    
                    if length(dw) > 1
                        result = 0;
                        return
                    end
                    
                    result = abs(mod(S.w(1), dw)) < eps('single');
                    
                    if ~result
                        wID = 'SeaState:checkSpectrum:badStart';
                        msg = ['First frequency in Spectrum #%i is not '...
                               'integer multiple of frequency step'];
                        warning(wID, msg, idx)
                    end
                    
                catch
                    result = 0;
                end
                
            end
            
            
            
            check{1} = @(Spect,idx) checkFields(Spect, idx);
            check{2} = @(Spect,idx) checkLengths(Spect, idx);
            check{3} = @(Spect,idx) checkCol(Spect, idx);
            check{4} = @(Spect,idx) checkPositive(Spect, idx);
            check{5} = @(Spect,idx) checkMonotonic(Spect, idx);
            check{6} = @(Spect,idx) checkRegular(Spect, idx);
            check{7} = @(Spect,idx) checkStart(Spect, idx);
            
            inds = 1:length(S);
            for ii = 1:length(check)
                pass(ii) = sum(arrayfun(check{ii}, S, inds));
            end
            
            if ~prod(pass)
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
            %        struct array that satisfies the
            %        :mat:meth:`+WecOptTool.SeaState.checkSpectrum` 
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
            %
            % Example:
            %
            %     >>> import WecOptTool.SeaState
            %     >>> S = WecOptTool.tests.data.exampleSpectrum();
            %     >>> e = SeaState.getSpecificEnergy(S);
            %     >>> disp(e)
            %        4.0264e+04
            %
            
            arguments
                S {WecOptTool.SeaState.checkSpectrum(S)}
                options.g {mustBeNumeric} = 9.81
                options.rho {mustBeNumeric, mustBePositive} = 1028
            end
            
            N = length(S);
            energies = zeros(1, N);
            
            for i = 1:N
                dw = uniquetol(diff(S(i).w), eps('single'));
                assert(length(dw) == 1)
                energies(i) = options.g * options.rho * dw * sum(S(i).S);
            end
            
        end
        
        function errors = getMaxAbsoluteDensityError(trueS, approxS)
            % Returns the maximum absolute error in spectral density 
            % between two spectra struct arrays.
            %
            % Arguments:
            %    trueS (struct):
            %        struct array representing the true value and satisfies
            %        :mat:meth:`+WecOptTool.SeaState.checkSpectrum` 
            %    approxS (struct):
            %        struct array representing the approximate value and 
            %        satisfies 
            %        :mat:meth:`+WecOptTool.SeaState.checkSpectrum`
            %
            % Returns:
            %     array: absolute error per spectrum [m\ :sup:`2` s/rad]
            %
            % Example:
            %     Find the maximum absolute error in spectral density
            %     in a spectrum after resampling
            %
            %     >>> import WecOptTool.SeaState
            %     >>> S = WecOptTool.tests.data.exampleSpectrum();
            %     >>> newS = SeaState.resampleByStep(S, 0.2);
            %     >>> error = SeaState.getMaxAbsoluteDensityError(S, newS);
            %     >>> disp(error)
            %         0.9136
            %
            
            arguments
                trueS {WecOptTool.SeaState.checkSpectrum(trueS)}
                approxS {WecOptTool.SeaState.checkSpectrum(approxS),	...
                         WecOptTool.validation.mustBeEqualLength(trueS, ...
                                                                 approxS)}
            end
            
            import WecOptTool.SeaState
            
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
            %        struct array representing the true value and satisfies
            %        :mat:meth:`+WecOptTool.SeaState.checkSpectrum` 
            %    approxS (struct):
            %        struct array representing the approximate value and 
            %        satisfies 
            %        :mat:meth:`+WecOptTool.SeaState.checkSpectrum`
            %
            % Returns:
            %     array: relative error per spectrum
            %
            % Example:
            %     Find the relative error in specific energy of a spectrum 
            %     after resampling
            %
            %     >>> import WecOptTool.SeaState
            %     >>> S = WecOptTool.tests.data.exampleSpectrum();
            %     >>> newS = SeaState.resampleByStep(S, 0.2);
            %     >>> error = SeaState.getRelativeEnergyError(S, newS);
            %     >>> disp(error)
            %         0.0010
            %
            
            arguments
                trueS {WecOptTool.SeaState.checkSpectrum(trueS)}
                approxS {WecOptTool.SeaState.checkSpectrum(approxS),    ...
                         WecOptTool.validation.mustBeEqualLength(trueS, ...
                                                                 approxS)}
            end
            
            import WecOptTool.SeaState
            
            baseEnergy = SeaState.getSpecificEnergy(trueS);
            interpEnergy = SeaState.getSpecificEnergy(approxS);

            errors = abs(interpEnergy ./ baseEnergy - 1);
            
        end

        function S = trimFrequencies(S, densityTolerence)
            % Removes frequencies below a threshold of the maximum spectral 
            % density from the tails, per spectra, of a spectra struct 
            % array.
            %
            % Arguments:
            %     S (struct):
            %         struct array that satisfies the
            %         :mat:meth:`+WecOptTool.SeaState.checkSpectrum` 
            %         method
            %     densityTolerence (float):
            %         Percentage of maximum spectral density
            %
            % Returns:
            %     struct: Sea state struct which conforms to 
            %     :mat:meth:`+WecOptTool.SeaState.checkSpectrum`
            %
            % Example:
            %     Remove frequencies containing less than 1% of the maximum
            %     spectral density
            %
            %     >>> import WecOptTool.SeaState
            %     >>> S = WecOptTool.tests.data.example8Spectra();
            %     >>> newS = SeaState.trimFrequencies(S, 0.01);
            %     
            
            arguments
                S {WecOptTool.SeaState.checkSpectrum(S)}
                densityTolerence {mustBeNumeric,    ...
                                  mustBePositive,   ...
                                  mustBeFinite,     ...
                                  mustBeNonzero}
            end
            
            for k = 1:length(S)
                iEnd = find(S(k).S > max(S(k).S) * densityTolerence,    ...
                            1,                                          ...
                            'last');
                S(k).w = S(k).w(1:iEnd);
                S(k).S = S(k).S(1:iEnd);
            end
            
        end
        
        function  S = extendFrequencies(S, nRepeats)
            % Adds multiples of the maximum frequency to a spectra struct 
            % array
            %
            % Arguments:
            %     S (struct):
            %         struct array that satisfies the
            %         :mat:meth:`+WecOptTool.SeaState.checkSpectrum` 
            %         method
            %     nRepeats (int):
            %         Number of repetitions of max frequency
            %
            % Returns:
            %     struct: Sea state struct which conforms to 
            %     :mat:meth:`+WecOptTool.SeaState.checkSpectrum`
            %
            % Example:
            %     Double the frequency range of the given spectrum
            %
            %     >>> import WecOptTool.SeaState
            %     >>> S = WecOptTool.tests.data.exampleSpectrum();
            %     >>> disp(max(S.w))
            %         3.2000
            %     <BLANKLINE>
            %     >>> Snew = SeaState.extendFrequencies(S, 2);
            %     >>> disp(max(Snew.w))
            %         6.4000
            %
            
            arguments
                S {WecOptTool.SeaState.checkSpectrum(S)}
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
            % Resample the given sea state struct based on the error in
            % spectral density normalized by the maximum per spectrum.
            % a maximum error of the maximum spectral density for a spectra
            % struct array.
            %
            % Arguments:
            %     S (struct):
            %         struct array that satisfies the
            %         :mat:meth:`+WecOptTool.SeaState.checkSpectrum` 
            %         method
            %     targetError (float):
            %         Target maximum error in normalized spectral density 
            %     min_dw (optional, float):
            %         Smallest frequency step to test, default = 1e-4
            %
            % Returns:
            %      :
            %     - S (struct): Sea state struct which conforms to 
            %       :mat:meth:`+WecOptTool.SeaState.checkSpectrum`
            %     - dw (array): Frequency spacings per spectrum
            %
            % Example:
            %     Resample such that the maximum absolute error in 
            %     spectral density is less that 5% of it's original
            %     maximum
            %
            %     >>> import WecOptTool.SeaState
            %     >>> S = WecOptTool.tests.data.exampleSpectrum();
            %     >>> newS = SeaState.resampleByError(S, 0.05);
            %     >>> error = SeaState.getMaxAbsoluteDensityError(S, newS);
            %     >>> disp(error / max(S.S))
            %         0.0500
            %
            
            arguments
                S {WecOptTool.SeaState.checkSpectrum(S)}
                targetError {mustBeNumeric,    ...
                             mustBePositive,   ...
                             mustBeFinite,     ...
                             mustBeNonzero}
                min_dw  {mustBeNumeric,    ...
                         mustBePositive,   ...
                         mustBeFinite,     ...
                         mustBeNonzero} = 1e-4
            end
            
            import WecOptTool.SeaState
            
            function residual = ObjFun(dw) 
                [~, errors] = SeaState.resampleByStep(S, dw);
                residual = max(errors) - targetError;
            end
            
            maxw = 0;
            
            for i = 1:length(S)
                testmax = max(S(i).w);
                if testmax > maxw
                    maxw = testmax;
                end
            end
            
            dw = WecOptTool.math.bisection(@ObjFun, min_dw, maxw);
            [S, errors] = SeaState.resampleByStep(S, dw);
            
        end
        
        function [S, errors] = resampleByStep(S, dw)
            % Resample the given sea state struct using a given frequency 
            % step
            %
            % Arguments:
            %     S (struct):
            %         struct array that satisfies the
            %         :mat:meth:`+WecOptTool.SeaState.checkSpectrum` 
            %         method
            %     dw (float):
            %         Angular frequency step size
            %
            % Returns:
            %      :
            %     - S (struct): Sea state struct which conforms to 
            %       :mat:meth:`+WecOptTool.SeaState.checkSpectrum`
            %     - errors (array): error in spectral density (normalized 
            %       by the maximum) per spectrum
            %
            % Example:
            %     Resample using a fixed angular frequency step of 0.2
            %
            %     >>> import WecOptTool.SeaState
            %     >>> S = WecOptTool.tests.data.exampleSpectrum();
            %     >>> newS = SeaState.resampleByStep(S, 0.2);
            %     >>> dw = uniquetol(diff(newS.w), eps('single'));
            %     >>> disp(dw)
            %         0.2000
            %
            
            arguments
                S {WecOptTool.SeaState.checkSpectrum(S)}
                dw {mustBeNumeric,  ...
                    mustBePositive, ...
                    mustBeFinite,   ...
                    mustBeNonzero}
            end
            
            import WecOptTool.SeaState
            
            N = length(S);
            baseS = S;
            maxS = 0;

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
                
                testmax = max(baseS(i).S);
                
                if testmax > maxS
                    maxS = testmax;
                end
                
            end
            
            abserrors = SeaState.getMaxAbsoluteDensityError(baseS, S);
            errors = abserrors ./ maxS;
            
        end
        
        function SS = exampleSpectrum(varargin)
            % Example Bretschneider spectrum with Hm0=8 and Tp=10
            p = mfilename('fullpath');
            [filepath, ~, ~] = fileparts(p);
            dataPath = fullfile(filepath, 'data', 'spectrum.mat');
            example_data = load(dataPath);
            SS = WecOptTool.SeaState(example_data.S, varargin{:});
        end
        
        function SS = example8Spectra(varargin)
            % Example Bretschneider spectrum with varying HHm0s, Tps, 
            % Nbins, and range
            p = mfilename('fullpath');
            [filepath, ~, ~] = fileparts(p);
            dataPath = fullfile(filepath, 'data', '8spectra.mat');
            example_data = load(dataPath);
            SS = WecOptTool.SeaState(example_data.SS, varargin{:});
        end
        
        function SS = regularWave(w, sdata, varargin)
            % Returns a regular wave using a WAFO-like struct
            %
            % Arguments:
            %     w (array): frequency vector
            %     sdata (array):
            %         [A, T], where A is the amplitude and T is the period
            %
            % Returns:
            %     :mat:class:`+WecOptTool.SeaState`: SeaState object
            %
            % See also jonswap

            if isempty(w)
                error('NOT YET IMPLEMENTED') % TODO - copy what WAFO does
            end

            assert(issorted(w));
            dws = diff(w);
            assert(all(abs(dws - dws(1)) < eps*1e3));
            assert(iscolumn(w));

            S.w = w;
            dw = dws(1);

            A = sdata(1);
            T = sdata(2);

            [~,idx] = min(abs(w - 2*pi/T));

            S.S = zeros(size(w));
            S.S(idx) = A^2/(2*dw);

            S.date = datestr(now);
            S.note =['Regular wave, A = ' num2str(A)  ', T = ' num2str(T)];
            S.type = 'freq';
            S.h = Inf;

            S.tr = [];
            S.phi = 0;
            S.norm = 0;

            SS = WecOptTool.SeaState(S, varargin{:});

        end
        
    end

end
