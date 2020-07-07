function S = regularWave(w,sdata,plotflag)
    % regularWave   returns a regular wave using a WAFO-like struct
    %
    % Inputs
    %   w           frequency vector
    %   sdata       [A, T], where A is the amplitude and T is the period
    %   plotflag    1 for plotting
    %
    % Outputs
    %   S           spectrum structure
    %
    % See also jonswap
    
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
    %     WecOptTool is distributed in the hope that it will be useful, but
    %     WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    %     General Public License for more details.
    %
    %     You should have received a copy of the GNU General Public License
    %     along with WecOptTool.  If not, see
    %     <https://www.gnu.org/licenses/>.
    
    if isempty(w)
        error('NOT YET IMPLEMENTED') % TODO - copy what WAFO does
    end
    
    if plotflag
        warning('NOT YET IMPLEMENTED') % TODO
    end
    
    assert(issorted(w));
    dws = diff(w);
    assert(all(dws - dws(1) < eps*1e3)); % TODO - not sure why == won't work
    assert(w(1) == dws(1));
    assert(iscolumn(w));
   
    S.w = w;
    dw = dws(1);
    
    A = sdata(1);
    T = sdata(2);
    
    [~,idx] = min(abs(w - 2*pi/T));
    
    S.S = zeros(size(w));
    S.S(idx) = A^2/(2*dw);
    
    S.date = datestr(now);
    S.note =['Regular wave, A = ' num2str(A)  ', T = ' num2str(T)];
    S.type = 'freq';
    S.h = Inf;
    
    S.tr = [];
    S.phi = 0;
    S.norm = 0;
    
    S = orderfields(S,{'S','w','tr','h','type','phi','norm','note','date'});
    
end