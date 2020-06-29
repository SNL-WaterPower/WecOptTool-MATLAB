function maape = MAAPError(actual, predicted)
    % Returns the mean arctangent absolute percentage error (MAAPE). MAAPE
    % is a modification to the mean absolute percentage error (MAPE) that 
    % maintains the intutiveness of the percentage error metric with the
    % added functionality of division by zero.         
    %
    % Kim, S., & Kim, H. (2016). A new metric of absolute percentage 
    %     error for intermittent demand forecasts. International Journal 
    %     of Forecasting, 32(3), 669-679.
    %
    % Parameters
    % ----------
    % actual: numeric
    %    The true values to compare to
    % predicited: numeric
    %    The predictied or modified values to calcualte the error of
    %
    % Returns
    % -------
    % mape: double
    %     The MAPE as a fraction 
    
% Copyright 2020 National Technology & Engineering Solutions of Sandia, 
% LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
% U.S. Government retains certain rights in this software.
%
% This file is part of WecOptTool.
% 
%     WecOptTool is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     WecOptTool is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with WecOptTool.  If not, see <https://www.gnu.org/licenses/>
    
    arguments
        actual    {mustBeNumeric, mustBeFinite}
        predicted {mustBeNumeric,   ...
                   mustBeFinite,    ...
                   WecOptLib.errorCheck.assertEqualLength(actual,   ...
                                                          predicted)}
    end
    
    nonZeroIdx = actual > eps;
    filterActual = actual(nonZeroIdx);
    filterPredicted = predicted(nonZeroIdx);
    
    N = length(filterActual);
    
    L1 = (1 - filterPredicted ./ filterActual );
    absL1 = abs(L1);
    atanAbsL1 = atan(absL1);
    maape =  1/N * sum(atanAbsL1);
    
end
