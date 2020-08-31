clear all
Te = 30;
Isat = 2;


if exist('plots') == 7
    rmdir('plots','s')
end
mkdir('plots')



% Vf_guess_coeff = (0:.1:1);
% Te_pred_coeff = (0:.1:1);

Vf_guess_coeff = (0:.01:2);
Te_pred_coeff = (0:.01:2);



Vf_over_Te = -(2);



for k = 1:length(Vf_over_Te)
Vf = Vf_over_Te(k)*Te;

clear Converge_or_no
Converge_or_no(length(Te_pred_coeff),length(Vf_guess_coeff)) = 0;
for i_Vf = 1:length(Vf_guess_coeff)
    for j_Te = 1:length(Te_pred_coeff)
        clearvars -except Te i_Vf j_Te  Vf  Isat Vf_guess_coeff Te_pred_coeff Converge_or_no k Vf_over_Te Vf_diff_og Te_diff_og
        Vf_guess =  Vf_guess_coeff(i_Vf)*Vf;
        Te_pred = Te_pred_coeff(j_Te)*Te;
        Isat_pred = 2;
        Vf_diff = Vf - Vf_guess;
        %Not currently ysed%%%%%%%%%%%%%%%%%
        Te_diff = Te - Te_pred;
        
        Vf_diff_og(i_Vf) = (Vf - Vf_guess)/Te;
        Te_diff_og(j_Te) = (Te_pred - Te)/Te;       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
storage(3,31) = 0;
storage(1,1) = Vf_diff;
storage(2,1) = Isat_pred;
storage(3,1) = Te_pred;
        
        for cycle = 1:30
%             I_LP = Current(real(Isat) , real(Te_pred),real(Te), -3);
%             Isat_pred = First_bias_state(real(Te_pred), real(Vf_diff), real(I_LP));
%             storage(4,cycle+1) = I_LP;
%             I_LP = Current(real(Isat) ,real(Te_pred),real(Te),  1);
%             Te_pred = Second_bias_state(real(Vf_diff), real(I_LP), real(Isat_pred),real(storage(3,cycle)));
%             storage(5,cycle+1) = I_LP;
%             I_LP = Current(real(Isat) ,real(Te_pred),real(Te), 0);
%             Vf_diff = Third_bias_state(real(Te_pred), real(I_LP), real(Isat_pred));
            
            I_LP = Current(Isat , Te_pred,Te, -3);
            Isat_pred = First_bias_state(Te_pred, Vf_diff, I_LP);
            storage(4,cycle+1) = I_LP;
            I_LP = Current(Isat ,Te_pred,Te,  1);
            Te_pred = Second_bias_state(Vf_diff, I_LP, Isat_pred,storage(3,cycle));
            storage(5,cycle+1) = I_LP;
            I_LP = Current(Isat ,Te_pred,Te, 0);
            Vf_diff = Third_bias_state(Te_pred, I_LP, Isat_pred);





            storage(1,cycle+1) = Vf_diff;
            storage(2,cycle+1) = Isat_pred;
            storage(3,cycle+1) = Te_pred;
            storage(6,cycle+1) = I_LP;
            
         end
        
        if isnan(storage(3,31))
            Converge_or_no(j_Te,i_Vf) = 1;
        end
        
        if storage(3,31) == 0;
            Converge_or_no(j_Te,i_Vf) = 2;
        end

    end
    
    
end
fig1 = figure(1);
clf('reset')
hold on
surf(Vf_guess_coeff,Te_pred_coeff,Converge_or_no,'edgecolor','none')
colorbar
%surf(Vf_diff_og,Te_diff_og,Converge_or_no)

view(2)
xlabel('Vf Guess / Vf')
ylabel('Te Guess / Te')
title(['Vf/Te = ',num2str(Vf_over_Te(k))])
img = getframe(fig1);
imwrite(img.cdata, ['plots/Vf_over_Te_index_',num2str(k),'.jpg'])



end









