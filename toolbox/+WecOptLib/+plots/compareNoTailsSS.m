function compareNoTailsSS(originalSS, noTailsSS)
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
        originalSS {WecOptLib.utils.checkSpectrum(originalSS)};
        noTailsSS {WecOptLib.utils.checkSpectrum(noTailsSS), ...
            WecOptLib.errorCheck.assertEqualLength(originalSS, noTailsSS)};
    end
    
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
        
        plot(wOrig, SOrig, markerOrig, 'DisplayName', labelOrig)
        plot(wMod,  SMod,  markerMod, 'DisplayName', labelMod)
        
        
        tailCutIn = min(wMod);
        tailCutOut= max(wMod);
        cutIn = [tailCutIn tailCutIn];
        cutOut = [tailCutOut tailCutOut];
        
        yMin=0;
        yMax=12;
                        
        plot(cutIn, [yMin yMax], '--', 'DisplayName', 'Cut In')
        plot(cutOut,[yMin yMax], '-.', 'DisplayName', 'Cut Out')
        
        legend()
        xlim([ 0  4])
        ylim([ yMin yMax])
        xlabel('Frequency [$\omega$]','Interpreter','latex')
        ylabel('Spectral Density','Interpreter','latex')
        grid                        
        
    end
            
end
