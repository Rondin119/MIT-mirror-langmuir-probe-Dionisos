clear all
Isat = -3200*1;
Te = 64*6;
VF = 2*64;
Te_pred = 64*10;
VF_pred = 64*0;
%Isat_pred = -3400*1;

 LB_Voltage(1) = -3.3*Te_pred+VF;
 LP_current(1) = Current(Isat, VF, Te, LB_Voltage(1));
 Isat_pred = First_bias_state(Te_pred, LB_Voltage(1), LP_current(1), VF_pred);

LB_Voltage(2) = .675*Te_pred+VF;
LP_current(2) = Current(Isat, VF, Te, LB_Voltage(2));
Te_pred = Second_bias_state(VF_pred,LP_current(2),Isat_pred,LB_Voltage(2));

LB_Voltage(3) = 0*Te+VF;
LP_current(3) = Current(Isat, VF, Te, LB_Voltage(3));
VF_pred = Third_bias_state(Te_pred,LP_current(3),Isat_pred,LB_Voltage(3));

















