
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

function downSampleSS = downSampleSpectra(SS, maxError, minBins)
    % downSampleSS takes a set of sea states and down samples the 
    % number of frequencies.
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
    
    %TEMPORARY HARDCODED PLOT FUNCTION 
    plot=false;

    WecOptLib.utils.checkSpectrum(SS);
    assertLengthOneOrLengthSS(maxError,SS)
    assertPositiveFloat(maxError)
    assertLengthOneOrLengthSS(minBins,SS)
    assertPositiveInt(minBins)
    assertMinBinsGreaterThanOne(minBins)
    assertBinsGreaterThanMinBins(SS,minBins) 
    
    downSampleSS = SS;
    for i =1:length(SS)
        w = SS(i).w;
        S = SS(i).S;        

        if length(minBins)==1
            minBin = minBins;
        elseif length(minBins)==length(SS)
            minBin = minBins(i);
        end
        
        [wNew, SNew] = downSample(w, S, maxError, minBin);

        downSampleSS(i).w = wNew;
        downSampleSS(i).S = SNew;               
    end
    
    %TEMPORARY HARDCODED PLOT FUNCTION 
    if plot==true
        plotDownSampledSS(SS, downSampleSS)
    end

end


function [wDownSampled, SDownSampled] = downSample(w, S, maxError, minBins)
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
    
    bins=length(S);
    error=0;
    while and(error < maxError, bins>=minBins)
        bins = bins-1;    
        wDownSampled = linspace(wMin,wMax,bins)';
        SDownSampled = interp1(w, S, wDownSampled);
        
        %check for NaNs e.g. isRealPositive
        
        error = MAPE(w,S,wDownSampled,SDownSampled);                
    end

    bins = bins+1;    
    wDownSampled = linspace(wMin,wMax,bins)';
    SDownSampled = interp1(w, S, wDownSampled);  
    
    error = MAPE(w,S,wDownSampled,SDownSampled);
    
    checkError(error, maxError)            
    compareWAndSpecrumLengths(wDownSampled,SDownSampled)
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


function [] = assertPositiveFloat(x)
    msgPos = [sprintf('%f must be a positive',x)];
    msgFloat = [sprintf('%f must be a float ',x)];
    ID = 'WecOptLib:utilityFailure:positiveFloat';   
    try
        assert(all(x>=0),ID,msgPos);
    catch ME
        throw(ME)
    end
    try
        assert(isa(x,'numeric'),ID,msgFloat);
    catch ME
        throw(ME)
    end
end


function [] = assertPositiveInt(x)
    msgInt = [sprintf('%f must be an Integer', x)];
    msgPos = [sprintf('%f must be positive ', x)];
    ID = 'WecOptLib:utilityFailure:positiveInt';      
    try        
        assert(all(x>=0),ID,msgPos);
    catch ME
        throw(ME)
    end
    
    try
        % isa(x,'integer') doen not work for x=1 default specification ;
        assert(all(mod(x,1)==0),ID,msgInt);
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


function [] = assertLengthOneOrLengthSS(x,SS)
    msg = 'x must be of length 1 or length of SS';
    ID = 'WecOptLib:utilityFailure:incorrectLength';
    try
        lenX = length(x);
        lenSS = length(SS);    
        assert(or(lenX==1, lenX==lenSS),ID,msg);
    catch ME
        throw(ME)
    end
end


function [] = assertMinBinsGreaterThanOne(minBins)
    msg = ['minBin values must be greater than 1'];
    ID = 'WecOptLib:utilityFailure:minBinsGreaterThanOne';
    try
        assert(all(minBins>1),ID,msg);
    catch ME
        throw(ME)
    end
end


function [] = assertBinsGreaterThanMinBins(SS,minBins)
    lenMinBins = length(minBins);
    if lenMinBins ==1
        msg = ['Length of spectra must be greater than or equal to the'...
               'specified minBins'];
        ID = 'WecOptLib:utilityFailure:SSBinsLessThanSingleMinBins';
        try
            for i=1:length(SS)    
                SBins = length(SS(i).S);
                assert(SBins>=minBins,ID,msg);
            end
        catch ME
            throw(ME)
        end
        
    elseif lenMinBins == length(SS)
        msg = ['Each minBin must be greater than or equal to the'...
               'associated Spectra'];
        ID = 'WecOptLib:utilityFailure:SSBinsLessThanMultiMinBins';
        try
            for i=1:length(SS)    
                minBin = minBins(i);
                SBins = length(SS(i).S);
                assert(SBins>=minBin,ID,msg);
            end
        catch ME
            throw(ME)
        end
    end
end


function plotDownSampledSS(SSOriginal, SSDownSampled)
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
    figureN = get(gcf,'Number');
    for i=1:length(SSOriginal)
        figure(figureN+i)
        hold on;
        
        wOrig = SSOriginal(i).w;
        SOrig = SSOriginal(i).S;
        wMod = SSDownSampled(i).w;
        SMod = SSDownSampled(i).S;
        
        
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
               
        error = MAPE(wOrig, SOrig, wMod, SMod);
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
