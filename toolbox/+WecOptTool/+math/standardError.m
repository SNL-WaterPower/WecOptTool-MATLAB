function [resultArray, extra] = standardError(resultType,       ...
                                              funHandle,        ...
                                              vectorLength,     ...
                                              resultStop,       ...
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
    %       argument.
    %   options: name-value pair options. See below.
    %
    % The following options are supported:
    %
    %    metric (string):
    %        the name of the metric used to calculate the standard error.
    %        The options are ``'sum'`` which sums the error over the result 
    %        vector, ``'max'`` which returns the greatest error in the 
    %        vector, or ``'summean'`` which returns the sum of the errors 
    %        divided by the sum of the mean of the result vector.
    %    targetField (string):
    %        if :attr:`funHandle` returns a struct then this option 
    %        indicates the field in the struct to use for the error 
    %        calculation.
    %
    % Returns:
    %      :
    %     - resultArray: array or struct containing the results of
    %       :attr:`funHandle` for each sample
    %     - extra: the error metric vector if :attr:`resultType` is 
    %       ``'measure'`` or the number of samples required if 
    %       :attr:`resultType` is ``'reduce'``
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
        options.metric (1, :) char {checkMetric} = 'sum';
        options.targetField (1, :) char;
    end
    
    switch options.metric
        case 'sum' 
            errorFun = @ (x, y) sum(x);
        case 'max'
            errorFun = @ (x, y) max(x);
        case 'summean' 
            errorFun = @ (x, y) sum(x) / sum(mean(y));
    end
    
    n = 0;
    calculatec4 = true;
    resultArray = zeros(1, vectorLength);
    
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
                    extra = n;
                    break
                end
                
            case 'measure'
                
                if n >= resultStop
                    extra = errorMetric;
                    break
                end
                
        end
        
    end
    
    if isfield(options, 'targetField')
        resultArray = structArray;
    end
    
end

function checkType(input)
    
    validModes = {'reduce' 'measure'};
    
    if ~matches(validModes, input)
        modeStr = sprintf(' "%s"', validModes{:});
        errStr = ['Result type not regonised. Must be one of' modeStr];
        error('WecOptTool:math:standardError', errStr)
    end
    
end

function checkMetric(input)
    
    validModes = {'sum' 'max' 'summean'};
    
    if ~matches(validModes, input)
        modeStr = sprintf(' "%s"', validModes{:});
        errStr = ['Error mode not regonised. Must be one of' modeStr];
        error('WecOptTool:math:standardError', errStr)
    end
    
end

function result = getc4(n)
    
    % Correction for unbiased estimate of the standard deviation.
    % https://en.wikipedia.org/wiki/Unbiased_estimation_of_standard_deviation
    
    a = sqrt(2 / (n - 1));
    b = gamma(n / 2) / gamma((n - 1) / 2);
    result = a * b;
    
end
