function [ current ] = Current( Isat, VF_real, Te_real, VB)
%CURRENT Summary of this function goes here
%   Detailed explanation goes here

current = Isat*(exp((VB-VF_real)/Te_real)-1);

end

