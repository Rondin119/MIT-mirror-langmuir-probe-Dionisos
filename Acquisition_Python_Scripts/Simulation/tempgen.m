function [y] = tempgen(x)
%TEMPGEN Summary of this function goes here
%   Detailed explanation goes here

y = 1./log(x+1);
if x<0
y=y*2^9;
elseif (x>0) && (x<=1)
 y=y*2^9;   
else
 y=y*2^13;   
end   
    
    
    
    
    
    
end

