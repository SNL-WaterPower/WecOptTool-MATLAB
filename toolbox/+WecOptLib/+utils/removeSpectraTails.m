
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

function noTailsSS = removeSpectraTails(SS, tailTolerence, minBins)
    % Removes the spectrum tails based on the provided tailTolerence such
    % that S > max(S)*tailTolerence/100 & length(S) >= minBins
    %
    % Parameters
    % ---------
    % SS: struct
    %    spectra or Spectrum
    % tailTolerence: float or array
    %    Maximum percentage error the modified spectra may return.
    %     A user may specify a single tolerence to use for all spectra or
    %     an array of tolerences to use for each spectra in SS
    % minBins: int or array
    %     Argument to specify a lower bound on the number of
    %     frequency bins used to describe a spectra (e.g. length(w)). 
    %     A user may specify a single minimum bin to use for all spectra or
    %     an array of minimum bins to use for each spectra in SS
    %
    % Returns
    % -------
    % noTailsSS: struct    
    %    spectra greater than the specified tailTolerence

    %TEMPORARY HARDCODED PLOT FUNCTION 
    plot=false;
    
    WecOptLib.utils.checkSpectrum(SS);
    assertLengthOneOrLengthSS(tailTolerence,SS)
    assertPositiveFloat(tailTolerence)
    assertLengthOneOrLengthSS(minBins,SS)
    assertPositiveInt(minBins)
    assertMinBinsGreaterThanOne(minBins)
    assertBinsGreaterThanMinBins(SS,minBins)    
                      
    noTailsSS = SS;
    for i =1:length(SS)        
        w = SS(i).w;
        S = SS(i).S;
               
        [noTailw, noTailS] = removeTails(w, S, tailTolerence);

         noTailsSS(i).w = noTailw;
         noTailsSS(i).S = noTailS;  
         
        if length(noTailw)< minBins
            msg=['Error: Returned specturm length less than minBins.'...
                'Consider lowering the tailTolerence'];
            disp(msg)
            break
        end
    end            
    
    WecOptLib.utils.checkSpectrum(noTailsSS);
    if plot==true
        plotNoTailsSS(SS, noTailsSS)
    end
end


function [noTailW, noTailS] = removeTails(w, S, tailTolerence)
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
    % noTailW : vector
    %    w less tails outside toerance
    % noTailS: vector
    %    S less tails outside toerance

    SS = struct;
    SS.w = w;
    SS.S = S;
    WecOptLib.utils.checkSpectrum(SS);
    clear SS
    assertPositiveFloat(tailTolerence)
        
    % Remove tails of the spectra; return indicies of the vals>tol% of max
    specGreaterThanTolerence = find(S > max(S)*tailTolerence/100);

    iStart = min(specGreaterThanTolerence);
    iEnd   = max(specGreaterThanTolerence);
    iSkip  = 1;
    
    assertGreaterThanOrEqual(iEnd, iStart)

    noTailW = w(iStart:iSkip:iEnd);
    noTailS = S(iStart:iSkip:iEnd);    

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
        

function [] = assertGreaterThanOrEqual(x, y)
    msg = ['x must be greater than or equal to y'];
    ID = 'WecOptLib:utilityFailure:greaterThanOrEqual';
    try
        assert(x>=y,ID,msg) ;
    catch ME
        throw(ME)
    end
end


function [] = assertEqualLength(x, y)
    msg = ['x and y must be of equal length'];
    ID = 'WecOptLib:utilityFailure:unequalLengths';
    try
        assert(length(x)==length(y),ID,msg);
    catch ME
        throw(ME)
    end
end

function plotNoTailsSS(originalSS, noTailsSS)
    % Creates plots for each SS comparing the orignal SS to the downSampled
    % SS
    %
    % Parameters
    % ----------
    % originalSS: struct
    %    The original spectrum
    % noTailsSS: struct
    %    The spectrum with the tails removed
    %
    % Returns
    % -------
    % plots comparing each sea-state
            
    WecOptLib.utils.checkSpectrum(originalSS);
    WecOptLib.utils.checkSpectrum(noTailsSS);
    assertEqualLength(originalSS, noTailsSS)
    
    figureN = get(gcf,'Number');
    
    for i=1:length(originalSS)
        figure(figureN + i)
        hold on;
        
        wOrig = originalSS(i).w;
        SOrig = originalSS(i).S;
        wMod = noTailsSS(i).w;
        SMod = noTailsSS(i).S;
        
        markerOrig = '-';
        markerMod  = 'o';
        
        labelOrig= sprintf('Original (N=%d)' ,length(wOrig));
        labelMod = sprintf('Removed Tails (N=%d)',length(wMod));
        
        plotWVersusS(wOrig, SOrig, markerOrig, labelOrig)
        plotWVersusS(wMod,  SMod,  markerMod, labelMod)
        
        
        tailCutIn = min(wMod);
        tailCutOut= max(wMod);
        cutIn = [tailCutIn tailCutIn];
        cutOut = [tailCutOut tailCutOut];
        
        yMin=0;
        yMax=12;
                        
        plotWVersusS(cutIn, [yMin yMax], '--', 'Cut In')
        plotWVersusS(cutOut,[yMin yMax], '-.', 'Cut Out')
        
        legend()
        xlim([ 0  4])
        ylim([ yMin yMax])
        xlabel('Frequency [$\omega$]','Interpreter','latex')
        ylabel('Spectral Density','Interpreter','latex')
        grid                        
        
    end
        
    
end

function plotWVersusS(w, S, marker, label)
    % Plots angular frequency versus Spectral Density    
    %
    % Parameters
    % ----------
    % w: vector
    %    Angular frequencies
    % S: vector
    %    Spectral Densities
    % marker: string
    %    marker used to plt
    % label: String
    %    legend label
    
    plot(w, S, marker, 'DisplayName', label)           
    
end
