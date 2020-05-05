
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

function downSampleSS = resampleSeaStates(SS, tailTolerence, maxError)
    % resampleSeaStates Takes a set of sea states and down samples the 
    % number of frequencies.
    %
    % Parameters
    % ---------
    % SS: struct
    %    spectra or Spectrum
    % maxError: float
    %    maximum percentage error the modified spectra may return
    %
    % Returns
    % -------
    % downSampledSS: struct
    %     

    WecOptLib.utils.checkSpectrum(SS);

    noTailsSS = SS;
    for i =1:length(SS)
        w = SS(i).w;
        S = SS(i).S;
           
        [wNew, SNew] = removeTails(w, S, tailTolerence);

        MAPError = MAPE(w,S,wNew,SNew);

        noTailsSS(i).w = wNew;
        noTailsSS(i).S = SNew;        
    end


    downSampleSS = noTailsSS;
    for i =1:length(noTailsSS)
        w = noTailsSS(i).w;
        S = noTailsSS(i).S;        

        [wNew, SNew] = downSample(w, S, maxError);

        downSampleSS(i).w = wNew;
        downSampleSS(i).S = SNew;               
    end
    
    plotReSampledSS(SS, downSampleSS)

end


function [wNew, SNew] = removeTails(w, S, tol)
    % Removes Spectra less than tol % of max(S)

    % Parameters
    %-----------
    % w: vector
    %    angular frequencies
    % S: vector
    %    Spectral densities
    % tol: float
    %    Percentage of maximum to include in spectrum
    %
    % Returns
    %--------
    % wNew : vector
    %    w less tails outside toerance
    % SNew: vector
    %    S less tails outside toerance

    % Ignore tails of the spectra; return indicies of the vals>tol% of max
    specGreaterThanTolerence = find(S > max(S)*tol/100);

    checkSpectrumLength(specGreaterThanTolerence)   

    iStart = min(specGreaterThanTolerence);
    iEnd   = max(specGreaterThanTolerence);
    iSkip  = 1;

    wNew = w(iStart:iSkip:iEnd);
    SNew = S(iStart:iSkip:iEnd);

    compareWAndSpecrumLengths(w,S)
end


function [wDownSampled, SDownSampled] = downSample(w, S, maxError)
    % Removes Spectra less than tol % of max(S)

    % Parameters
    %-----------
    % w: vector
    %    angular frequencies
    % S: vector
    %    Spectral densities
    % maxError: float
    %    Percent maximum error the resampled data can have by MAPE
    %
    % Returns
    %--------
    % wDownSampled : vector
    %    w of less frequency bins 
    % SDownSampled: vector
    %    S less or equal 

    wMin=min(w);
    wMax=max(w);
    
    N=length(S);
    error=0;
    while error < maxError
        N = N-1;    
        wDownSampled = linspace(wMin,wMax,N)';
        SDownSampled = interp1(w, S, wDownSampled);
        
        %check for NaNs e.g. isRealPositive
        
        error = MAPE(w,S,wDownSampled,SDownSampled);                
    end
    disp(error)
    N = N+1;    
    wDownSampled = linspace(wMin,wMax,N)';
    SDownSampled = interp1(w, S, wDownSampled);       
    error = MAPE(w,S,wDownSampled,SDownSampled);
    
    checkError(error, maxError)            
    compareWAndSpecrumLengths(wDownSampled,SDownSampled)
end


function err = RMSE(wOriginal, SOriginal, wModified, SModified)
    % Calculates root mean squre error by interpolating the modified
    % spectrum to the original spectrum frequencies.
  
    interpolatedS = interp1(wModified, SModified, wOriginal);
    
    err = sqrt( sum( (SOriginal-interpolatedS)^2 ./ length(SOriginal) ) ) ;    
end


function err = MAPE(wOriginal, SOriginal, wModified, SModified)
    % Returns the mean absolute percentage error given an original and
    % modified spectrum to the original spectrum frequencies
  
    SInterpolated = interp1(wModified, SModified, wOriginal,'linear', 0);
    
    N = length(SOriginal);
    
    if any(SOriginal == 0)
        shiftZeroFrequencies=0.000001;
        SOriginal     = SOriginal     + shiftZeroFrequencies;
        SInterpolated = SInterpolated + shiftZeroFrequencies;
    end
    
    err =  100/N * sum( abs(1 - SInterpolated ./ SOriginal ))   ;
end


function [] = checkSpectrumLength(S)
    msg = ['Returned spectrum of length 1, try setting tolerence lower'];
    ID = 'WecOptLib:utilityFailure:tolerence';
    try
        assert(length(S)>1,ID,msg) ;
    catch ME
        throw(ME)
    end
end


function [] = compareWAndSpecrumLengths(w,S)
msg = 'w and S must be of same length';
ID = 'WecOptLib:utilityFailure:unequalLengths';
    try
        Nw = length(w);
        NS = length(S);
        assert(Nw == NS,ID,msg);
    catch ME
        throw(ME)
    end
end


function [] = checkError(error, maxError)
    msg = ['Error must be less than maxError'];
    ID = 'WecOptLib:utilityFailure:errorTooHigh';
    try
        assert(error<maxError,ID,msg) ;
    catch ME
        throw(ME)
    end
end


function plotReSampledSS(SSOriginal, SSReSampled)
    % Creates plots for each SS comparing the orignal SS to the downSampled
    % SS
    %
    % Parameters
    % ----------
    % SSOriginal: struct
    %    The original spectrum
    % SSReSampled: struct
    %    The down sampledspectrum
    %
    % Returns
    % -------
    % plots comparing each sea-state
    
    
    %assert(len(SS)==len(SSNew))
    % checkSpectrum
    
    for i=1:length(SSOriginal)
        figure(i)
        hold on;
        
        wOrig = SSOriginal(i).w;
        SOrig = SSOriginal(i).S;
        wMod = SSReSampled(i).w;
        SMod = SSReSampled(i).S;
        
        
        labelOrig= sprintf('Original (N=%d)' ,length(wOrig));
        labelMod = sprintf('Resampled (N=%d)',length(wMod));
        
        plotWVersusS(wOrig, SOrig, labelOrig)
        plotWVersusS(wMod,  SMod,  labelMod)
        
        legend()
        xlim([ 0  4])
        ylim([ 0 12])
        xlabel('Frequency [$\omega$]','Interpreter','latex')
        ylabel('Spectral Density','Interpreter','latex')
        grid
        
        tol=1;
        [w4ErrMetric, S4ErrorMetric] = removeTails(wOrig, SOrig, tol);
        
        error = MAPE(w4ErrMetric, S4ErrorMetric, wMod, SMod);
        title(sprintf('Fitting Error: %.2f%%', error))
        
    end
        
    
end

function plotWVersusS(w, S, label)
    % Plots angular frequency versus Spectral Density    
    %
    % Parameters
    % ----------
    % w: vector
    %    Angular frequencies
    % S: vector
    %    Spectral Densities
    % label: String
    %    legend label
    
    plot(w, S,'DisplayName',label)           
    
end
