function result = isClose(a, b, varargin)
    % Determine if two values are numerically close (but perhaps not
    % exactly equal).
    %
    % Args:
    %   a (double): first value to compare
    %   b (double): second value to compare
    %   rtol (double, optional): relative tolerence, default = 1e-05
    %   atol (double, optional): absolute tolerance, default = 1e-08
    %
    % Returns:
    %   logical: true if a is within given tolerances of b
    %
    % Note:
    %   Derived from the similar named `numpy routine
    %   <https://numpy.org/doc/stable/reference/generated/numpy.isclose.html>`_
    %
    
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
    %     WecOptTool is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %     GNU General Public License for more details.
    % 
    %     You should have received a copy of the GNU General Public 
    %     License along with WecOptTool.  If not, see 
    %     <https://www.gnu.org/licenses/>. 
    %
    % Copyright (C) 2005-2020, NumPy Developers.
    % All rights reserved.
    % 
    % Redistribution and use in source and binary forms, with or without 
    % modification, are permitted provided that the following conditions 
    % are met: 
    % 
    % * Redistributions of source code must retain the above copyright 
    % notice, this list of conditions and the following disclaimer. 
    % 
    % * Redistributions in binary form must reproduce the above copyright 
    % notice, this list of conditions and the following disclaimer in the 
    % documentation and/or other materials provided with the distribution. 
    % 
    % * Neither the name of the NumPy Developers nor the names of any 
    % contributors may be used to endorse or promote products derived from 
    % this software without specific prior written permission. 
    % 
    % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
    % "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    % LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    % FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    % COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    % INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    % BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    % LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    % CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    % LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    % ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    % POSSIBILITY OF SUCH DAMAGE. 

    defaultAtol = 1e-08;
    defaultRtol = 1e-05;
    
    p = inputParser;
    
    addParameter(p, 'rtol', defaultRtol);
    addParameter(p, 'atol', defaultAtol);
    parse(p, varargin{:});
    
    result = abs(a - b) <= (p.Results.atol + p.Results.rtol * abs(b));
    
end

