function SSResampled = resampleSpectra(SS, dw, NSuperHarmonics,wMin,wMax)
    % Takes a set of sea states and resamples the spectrum
    % based on a provided angular frequency discritization ('dw') and 
    % number of super harmonics to consider (NSuperHarmonics). 
    % 'dw' must be specified either as a field on 
    % the passed struct (SS) or as a parameter passed as an inputParser.
    % The 'wMin' and 'wMax' of the range may be supplied as struct fields
    % or as parameters in the inputParser. If not supplied reSampleSpectra 
    % will use the current range. Wether supplied or not the values will be
    % adjusted to ensure that the min and max are an integer multiple of 
    % the supplied 'dw'.
    %
    % Parameters
    % ---------
    % SS: struct
    %    spectra or Spectrum 
    % dw: numeric
    %        specifies the frequency discrtization
    % NSuperHarmonics: int
    %        Number of super harmoics to consider
    % wMin: float
    %       Specifies the minimum frequency. Will be modified if not an
    %       iteger multple of 'dw'
    % wMax: float
    %       Specifies the maximum frequency. Will be modified if not an
    %       iteger multple of 'dw'    
    %
    % Returns
    % -------
    % resampledSS: struct
    %     struct of down-sampled sea states
    
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
%     along with WecOptTool.  If not, see <https://www.gnu.org/licenses/>.
    
    arguments
        SS {WecOptLib.utils.checkSpectrum(SS)};
        dw {mustBePositive, mustBeFinite, mustBeNonzero,...
            WecOptLib.errorCheck.assertLengthOneOrLengthSS(dw,SS)};
        NSuperHarmonics {mustBePositive, mustBeInteger,...
            WecOptLib.errorCheck.assertLengthOneOrLengthSS(NSuperHarmonics,SS)}...
                        =6;
        wMin {mustBePositive, mustBeFinite, mustBeNonzero, ...
             WecOptLib.errorCheck.assertLengthOneOrLengthSS(wMin,SS)} ...
             = WecOptLib.utils.getStructFieldMin(SS,'w');
        wMax {mustBePositive, mustBeFinite, mustBeNonzero, ...
            WecOptLib.errorCheck.assertLengthOneOrLengthSS(wMax,SS), ...
            WecOptLib.errorCheck.checkMinMaxStepRange(wMin,wMax,dw)} ...
            = WecOptLib.utils.getStructFieldMax(SS,'w');
    end
        
    N=length(SS);    
    if length(dw) ~= N 
        dw = dw*ones(length(SS),1);
    end
    if length(NSuperHarmonics)~=N
        NSuperHarmonics = NSuperHarmonics*ones(N,1);
    end
    if length(wMin) ~= N
        wMin = wMin*ones(N,1);
    end
    if length(wMax) ~= N
        wMax = wMax*ones(N,1);
    end
        
    SSResampled = SS;
    for i =1:N                
                
        wIntegerStepMin = floor(wMin(i) / dw(i)) * dw(i);
        wIntegerStepMax = ceil(wMax(i) / dw(i)) * dw(i);                                
        
        wResampled = wIntegerStepMin:dw(i):wIntegerStepMax*NSuperHarmonics(i);
        wResampled = wResampled';
        
        WecOptLib.errorCheck.checkMinMaxStepRange(min(wResampled), max(wResampled), dw(i))
        
        wOrig = SS(i).w;
        SOrig = SS(i).S;  

        SResampled = interp1(wOrig, SOrig, wResampled, 'linear', 0);      
                
        SSResampled(i).w = wResampled;
        SSResampled(i).S = SResampled ;  
        
        wMinNoExtrap = min(wOrig);
        wMaxNoExtrap = max(wOrig);
        indexNoExtrap = (wResampled>wMinNoExtrap & wResampled < wMaxNoExtrap);
        wResampledNoExtrap = wResampled(indexNoExtrap);
        SResampledNoExtrap = SResampled(indexNoExtrap);
        
        SNoExtrapOrigInterpolated = interp1(wResampledNoExtrap, ...
                                            SResampledNoExtrap, ...
                                            wOrig,'linear', 0);
        
        errorNoExtrap = WecOptLib.utils.MAAPError(SOrig,...
                                                  SNoExtrapOrigInterpolated);
        SSResampled(i).resampleError = errorNoExtrap;                                  
        
    end
    

end
