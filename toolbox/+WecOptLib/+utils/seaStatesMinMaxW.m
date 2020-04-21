function [gMin,gMax] = seaStatesMinMaxW(SS)
%SEASTATESMINMAX Takes a set of sea states and returns the global min and 
% max frequency 

gMin=999;
gMax=-999;

for i =1:length(SS)
 
 w = SS(i).w;
 wMin = min(w);
 wMax = max(w);
 
 if wMin < gMin
     gMin = wMin;
 end
 
 if wMax > gMax
     gMax = wMax;
 end
end

