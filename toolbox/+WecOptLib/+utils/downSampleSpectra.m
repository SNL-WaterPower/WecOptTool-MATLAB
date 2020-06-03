function downSampleSS = downSampleSpectra(SS, maxError, minBins)
    % downSampleSpectra takes a set of sea states and down samples the 
    % number of frequencies of each spectra to be within a specified 
    % maxError and/ or minimum number of bins.
    %
    % Parameters
    % ---------
    % SS: struct
    %    spectra or Spectrum
    % maxError: float or array of floats
    %    maximum percentage error the down-sampled spectra may return
    %     A user may specify a single maxError to use for all spectra or
    %     an array of maxErrors to use for each spectra in SS    
    % minBins: int or array
    %     Argument to specify a lower bound on the number of
    %     frequency bins used to describe a spectra (e.g. length(w)). 
    %     A user may specify a single minimum bin to use for all spectra or
    %     an array of minimum bins to use for each spectra in SS
    %
    % Returns
    % -------
    % downSampledSS: struct
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
        maxError {mustBeNumeric, mustBePositive, mustBeFinite, ...
                  WecOptLib.errorCheck.assertLengthOneOrLengthSS(maxError,SS)...
                  } = 0.01 ;
        minBins  {mustBeNumeric, mustBePositive, mustBeFinite, ...
                  mustBeGreaterThan(minBins,1), ...
                  WecOptLib.utils.assertStructFieldLengthGreaterThanOrEqualToReference(SS,'S',minBins)...
                  WecOptLib.errorCheck.assertLengthOneOrLengthSS(minBins,SS)...
                  } = 10;
    end
                           
    
    downSampleSS = SS;
    for i =1:length(SS)
        w = SS(i).w;
        S = SS(i).S;        

        if length(minBins)==1
            minBin = minBins;
        elseif length(minBins)==length(SS)
            minBin = minBins(i);
        end
        
        [wNew, SNew, err] = downSample(w, S, maxError, minBin);

        downSampleSS(i).w = wNew;
        downSampleSS(i).S = SNew;  
        downSampleSS(i).downSampleError = err;
        
    end    
end


function [wDownSampled, SDownSampled, err] = downSample(w, S, maxError, minBins)
    % Removes Spectra less than tol % of max(S)
    %
    % Parameters
    % ----------
    % w: vector
    %    angular frequencies
    % S: vector
    %    Spectral densities
    % maxError: float
    %    Percent maximum error the resampled data can have by MAAPE
    %
    % Returns
    % -------
    % wDownSampled : vector
    %    down sampled frequency bins 
    % SDownSampled: vector
    %    Spectral densities associtated with wDownSampled

    wMin=min(w);
    wMax=max(w);
    
    bins=length(S);
    err=0;
    while and(err < maxError, bins>=minBins)
        bins = bins-1;    
        wDownSampled = linspace(wMin,wMax,bins)';
        SDownSampled = interp1(w, S, wDownSampled);        
        mustBeFinite(SDownSampled)
        SOrigInterpolated = interp1(wDownSampled, SDownSampled, w,'linear', 0);        
        err = WecOptLib.utils.MAAPError(S,SOrigInterpolated);                
    end

    bins = bins+1;    
    wDownSampled = linspace(wMin,wMax,bins)';
    SDownSampled = interp1(w, S, wDownSampled);  
    
    SOrigInterpolated = interp1(wDownSampled, SDownSampled, w,'linear', 0);                    
    err = WecOptLib.utils.MAAPError(S,SOrigInterpolated );
    
    mustBeLessThan(err,maxError)         
    WecOptLib.errorCheck.assertEqualLength(wDownSampled,SDownSampled)
        
end
