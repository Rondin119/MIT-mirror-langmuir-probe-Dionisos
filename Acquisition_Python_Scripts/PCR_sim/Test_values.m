function [LB_Esat, LB_zero, LB_Isat, Esat_out, Isat_out] = Test_values(Te,Vf,Isat)
%TEST_VALUES Summary of this function goes here
%   Detailed explanation goes here

Bias_low = -33.25;
%Bias_low = -100;
Bias_hi = 6.75;

LB_Esat = Bias_hi + Vf;
LB_Isat = Bias_low + Vf;
LB_zero = + Vf;

f = @(bias,Te,Vf,Isat) Isat*(exp((bias-Vf)/Te)-1);


Isat_out = f(LB_Isat,Te,Vf,Isat);
Esat_out = f(LB_Esat,Te,Vf,Isat);

LB_Esat = LB_Esat*64*2^13/6400;
LB_Isat = LB_Isat*64*2^13/6400;
LB_zero = LB_zero*64*2^13/6400;

Isat_out = Isat_out*3200*2^13/6400;
Esat_out = Esat_out*3200*2^13/6400;


end

