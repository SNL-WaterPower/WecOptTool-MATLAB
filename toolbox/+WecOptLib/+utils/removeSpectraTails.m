function noTailsSS = removeSpectraTails(SS, tailTolerence, minBins)
    % Removes the spectrum tails based on the provided tailTolerence such
    % that S > max(S)*tailTolerence & length(S) >= minBins
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
        tailTolerence           ...
            {mustBePositive,    ...
             mustBeNumeric,     ...
             mustBeFinite,      ...
             WecOptLib.errorCheck.assertLengthOneOrLengthSS(    ...
                                            tailTolerence, SS)} = 0.01;
        minBins {mustBeInteger, mustBePositive,mustBeGreaterThan(minBins,1)...
                 WecOptLib.errorCheck.assertLengthOneOrLengthSS(minBins,SS),...
                 WecOptLib.utils.assertStructFieldLengthGreaterThanOrEqualToReference(SS,'S',minBins)...
                } = 10;
    end
                          
    noTailsSS = SS;
    for i =1:length(SS)        
        w = SS(i).w;
        S = SS(i).S;
               
        [noTailw, noTailS] = removeTails(w, S, tailTolerence);

         noTailsSS(i).w = noTailw;
         noTailsSS(i).S = noTailS;  
         
        if length(noTailw)< minBins
            msg=['Error: Returned specturm length less than minBins. '...
                'Consider lowering the tailTolerence'];
            error(msg)
        end
    end            
    
    WecOptLib.utils.checkSpectrum(noTailsSS);

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
    
        
    % Remove tails of the spectra; return indicies of the vals>tol% of max
    specGreaterThanTolerence = find(S > max(S)*tailTolerence);

    iStart = min(specGreaterThanTolerence);
    iEnd   = max(specGreaterThanTolerence);
    iSkip  = 1;
    
    mustBeGreaterThanOrEqual(iEnd, iStart)

    noTailW = w(iStart:iSkip:iEnd);
    noTailS = S(iStart:iSkip:iEnd);    

end
