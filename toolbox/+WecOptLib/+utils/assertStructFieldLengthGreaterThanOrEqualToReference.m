function [] = assertStructFieldLengthGreaterThanOrEqualToReference(SS,field,minN)
    % Returns an error if the length of the field in the struct is not
    % greater than or equal to some specified minimum.
    %
    % Parameters
    % ----------
    % SS: struct
    %    struct with "field"  to check length against minN
    % field: string
    %    field in struct to check length 
    % minN: integer or vector of integers
    %    minimum to comapre length(SS.field) to. If single value all
    %    length(SS.field)> minN. If vector length(SS(i).field)> minN(i).
    %
    % Returns
    % -------
    % Error if the length(SS.field) is not greater than minN. Otherwise
    % pass.
    
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
    
    WecOptLib.errorCheck.assertIsField(SS,field)
    WecOptLib.errorCheck.assertLengthOneOrLengthSS(minN,SS)
    
    lenMinN = length(minN);
    if lenMinN ==1
        msg = ['Length of spectra must be greater than or equal to the'...
               'specified minN'];
        ID = 'WecOptLib:utilityFailure:SSBinsLessThanSingleMinBins';
        try
            for i=1:length(SS)    
                vals = SS.(field);
                fieldBins = length(vals);
                assert(fieldBins>=minN,ID,msg);
            end
        catch ME
            throw(ME)
        end
        
    elseif lenMinN == length(SS)
        msg = ['Each minN must be greater than or equal to the'...
               'associated Spectra field'];
        ID = 'WecOptLib:errorCheckFailure:SSBinsLessThanMultiMinBins';
        try
            for i=1:length(SS)    
                minBin = minN(i);
                vals = SS(i).(field);
                fieldBins = length(vals);
                assert(fieldBins>=minBin,ID,msg);
            end
        catch ME
            throw(ME)
        end
    end
end