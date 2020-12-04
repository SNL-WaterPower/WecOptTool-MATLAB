function [resultArray, stdEerror, N] = standardError(resultType,    ...
                                                     funHandle,     ...
                                                     vectorLength,  ...
                                                     resultStop,    ...
                                                     options)
    % Calculates the standard error of the mean of a given function.
    %
    % This function can either be used to reduce the standard error to
    % a certain level or calculate the standard error given a fixed number
    % of samples.
    %
    % Args:
    %   resultType (char):
    %       solution mode. Use ``'measure'`` to measure the standard error
    %       or ``'reduce'`` to reduce it.
    %   funHandle (function handle):
    %       function to evaluate. Should return a vector or a struct (of
    %       vectors). The ``'targetField'`` optional argument must be given
    %       if the function returns a struct.
    %   vectorLength (int32):
    %       length of the vector (or vector field) returned by 
    %       :attr:`funHandle`
    %   resultStop (double):
    %       termination criteria. If :attr:`resultType` is ``'measure'`` 
    %       then this argument represents the number of samples to be used. 
    %       If :attr:`resultType` is ``'reduce'`` then this is the value 
    %       returned by the metric selected using the ``'metric'`` optional
    %       argument. The ``'maxN'`` optional argument provides the maximum 
    %       number of samples allowed when in ``'reduce'`` mode.
    %   options: name-value pair options. See below.
    %
    % The following options are supported:
    %
    %    metric (string):
    %        the name of the metric used to calculate the standard error.
    %        The options are ``'norm'`` which norms the error over the 
    %        result vector, ``'max'`` which returns the greatest error in 
    %        the vector, or ``'normmean'`` which returns the norm of the 
    %        errors divided by the sum of the mean of the result vector.
    %        Default is ``'norm'``.
    %    targetField (string):
    %        if :attr:`funHandle` returns a struct then this option 
    %        indicates the field in the struct to use for the error 
    %        calculation.
    %    maxN (int32): 
    %        the maximum number of samples allowed when :attr:`resultType` 
    %        is ``'reduce'``. Triggers an error if exceeded.
    %    onError (string):
    %        action to take on error. If ``'warn'`` a warning will be
    %        issued, if ``'raise'`` an error will be raised. Default is
    %        ``'warn'``.
    %
    % Returns:
    %      :
    %     - resultArray: array or struct containing the results of
    %       :attr:`funHandle` for each sample
    %     - stdEerror: the standard error metric vector
    %     - N: the number of samples evaluated
    %
    % Note:
    %     The standard error is calculated on each element of the vector
    %     (or vector field) returned by :attr:`funHandle`. The ``'metric'`` 
    %     option indicates how these values should be combined into a 
    %     single metric
    %

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
    
    arguments
        resultType (1, :) char {checkType}
        funHandle (1, 1) {WecOptTool.validation.mustBeFunctionHandle}
        vectorLength (1, 1) int32 {mustBePositive}
        resultStop (1, 1) double {mustBePositive}
        options.metric (1, :) char {checkMetric} = 'norm'
        options.targetField (1, :) char
        options.maxN (1, 1) int32 {mustBePositive}
        options.onError  (1, :) char {checkError} = 'warn'
    end
    
    switch options.metric
        case 'norm' 
            errorFun = @ (x, y) norm(x);
        case 'max'
            errorFun = @ (x, y) max(x);
        case 'normmean' 
            errorFun = @ (x, y) norm(x) / sum(mean(y));
    end
    
    n = 0;
    calculatec4 = true;
    resultArray = zeros(1, vectorLength);
    
    if isfield(options, 'maxN') && strcmp(resultType, 'reduce')
        stopN = options.maxN;
    else
        stopN = Inf;
    end
    
    while true
        
        n = n + 1;
        
        if isfield(options, 'targetField')
            structArray(n) = funHandle();
            resultArray(n, :) = structArray(n).(options.targetField);
        else
            resultArray(n, :) = funHandle();
        end
        
        if n < 2
            continue
        end
        
        % The c4 calculation fails at large n
        if calculatec4
            c4 = getc4(n);
            if isnan(c4) || isinf(c4)
                c4 = 1;
                calculatec4 = false;
            end
        end
        
        resultError = c4 * std(resultArray) / sqrt(n);
        errorMetric = errorFun(resultError, resultArray);
        
        % Exit on different strategies
        switch resultType
            
            case 'reduce'
                
                if errorMetric <= resultStop
                    break
                end
                
            case 'measure'
                
                if n >= resultStop
                    break
                end
                
        end
        
        if n == stopN
            
            errStr = ['Target accuracy not reached before max '   ...
                        'samples. Final standard error is %f'];
            errCode = 'WecOptTool:standardError:maxNReached';
            
            switch options.onError
                case 'warn'
                    warning(errCode, errStr, errorMetric)
                case 'raise'
                    error(errCode, errStr, errorMetric)
            end
            
            break
            
        end
        
    end
    
    if isfield(options, 'targetField')
        resultArray = structArray;
    end
    
    stdEerror = errorMetric;
    N = n;
    
end

function checkType(input)
    
    validModes = {'reduce' 'measure'};
    
    if ~matches(validModes, input)
        modeStr = sprintf(' "%s"', validModes{:});
        errStr = ['Result type not regonised. Must be one of' modeStr];
        error('WecOptTool:standardError:badResultType', errStr)
    end
    
end

function checkMetric(input)
    
    validModes = {'norm' 'max' 'normmean'};
    
    if ~matches(validModes, input)
        modeStr = sprintf(' "%s"', validModes{:});
        errStr = ['Metric type regonised. Must be one of' modeStr];
        error('WecOptTool:standardError:badMetric', errStr)
    end
    
end

function checkError(input)
    
    validModes = {'warn' 'raise'};
    
    if ~matches(validModes, input)
        modeStr = sprintf(' "%s"', validModes{:});
        errStr = ['Error mode not regonised. Must be one of' modeStr];
        error('WecOptTool:standardError:badErrorMode', errStr)
    end
    
end

function result = getc4(n)
    
    % Correction for unbiased estimate of the standard deviation.
    % https://en.wikipedia.org/wiki/Unbiased_estimation_of_standard_deviation
    
    a = sqrt(2 / (n - 1));
    b = gamma(n / 2) / gamma((n - 1) / 2);
    result = a * b;
    
end
