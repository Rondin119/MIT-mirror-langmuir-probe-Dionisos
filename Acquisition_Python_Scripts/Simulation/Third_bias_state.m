function [ VF_pred ] = Third_bias_state( T, I_LP, ISat, V_LB )
%THIRD_BIAS_STATE Summary of this function goes here
%   Detailed explanation goes here

VF_pred = V_LB-T*log(I_LP/ISat+1);





end

