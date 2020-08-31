function [ T_e ] = Second_bias_state( VF, I_LP, I_S,V_LB )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

T_e = (V_LB-VF)./log(I_LP/I_S+1);


end

