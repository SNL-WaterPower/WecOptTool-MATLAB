function compareSpectra(SSOriginal, SSModified, errorField)
    % Creates plots for each sea state comparing the orignal resampled
    % SS 
    %
    % Parameters
    % ----------
    % SSOriginal: struct
    %    The original spectrum
    % SSResampled: struct
    %    The resampled spectrum
    % errorField: string or None
    %    field in SSResampled to get the error from. This value is
    %    inserted in the title of the plot. To ignore this pass nan.
    %    Field strings 'downSampleError' & 'resampledError' are expected
    %    to be set by the functions 'downSampleSpectra' and 
    %    'resampleSpectra' respectively.
    %
    % Returns
    % -------
    % plots comparing each sea-state
    % Plots Spectral density (S) for each angular frequency (w) for each
    % sea state passed
    %
        
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
        SSOriginal {WecOptLib.utils.checkSpectrum(SSOriginal)};
        SSModified  {WecOptLib.utils.checkSpectrum(SSModified), ...
            WecOptLib.errorCheck.assertEqualLength(SSOriginal, SSModified)};
        errorField char = 'None';        
    end
    
    figureN = get(gcf,'Number');
    for i=1:length(SSOriginal)
        figure(figureN+i)
        hold on;
        
        wOrig = SSOriginal(i).w;
        SOrig = SSOriginal(i).S;
        wMod = SSModified(i).w;
        SMod = SSModified(i).S;
        
        
        labelOrig= sprintf('Original (Bins=%d)' ,length(wOrig));
        labelMod = sprintf('Modified (Bins=%d)',length(wMod));
        
        plot(wOrig, SOrig,'DisplayName', labelOrig)
        plot(wMod, SMod,'DisplayName', labelMod)
        
        legend()
        xlim([ 0  4])
        ylim([ 0 12])
        xlabel('Frequency [$\omega$]','Interpreter','latex')
        ylabel('Spectral Density','Interpreter','latex')
        grid
        
        if isfield(SSModified(i),errorField)                
            errorVal = SSModified(i).(errorField);
            if strcmp(errorField, 'resampleError')
                title(sprintf('Fitting Error (No Extrapolation): %.2f%%', errorVal*100))                    
            elseif strcmp(errorField,'downSampleError')        
                title(sprintf('Fitting Error : %.2f%%', errorVal*100))                    
            else
                title(sprintf('Error : %.2f%', errorVal*100))
            end                                        
        end
    end
        
    
end
