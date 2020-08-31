function [] = readdata(data)
%READDATA Summary of this function goes here
%   Detailed explanation goes here

bit = fliplr(de2bi(data));

time = bit(2:6);
temp = bit(7:14);
isat = bit(15:23);
vf   = bit(24:32);

    function [y] = mybi2de(x)
        y = bin2dec( erase(join(string(x)),' '));
    end

temp = mybi2de(temp)
if isat(1) == 1
    isat = double(~(isat == 1));
    isat = -mybi2de(isat)
    
    
else
    isat = mybi2de(isat)
end

if vf(1) == 1
    vf = double(~(vf == 1));
    vf = -mybi2de(vf)
else
    vf = mybi2de(vf)
end
end

