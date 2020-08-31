function [ I_s ] = First_bias_state( T, V_LB, I_LP, VF )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

I_s = I_LP/(exp((V_LB-VF)/T)-1);

end

