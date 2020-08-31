clear all

%% Read in Data and arrange it into Bias states
%cd Data
Data = csvread('MLP_test_data_Shot_1_cal.csv',1,0);
%cd ../
MLP_Time_stamp = Data(:,1)+eps;
MLP_Current = Data(:,2)*2+eps;
MLP_Bias = Data(:,3)*2+eps;

excise_data_start = [];
excise_data_end = [];

[Bias_states,Current_states,Clock_cycles_states,Time_stamp_states] = clean_data(MLP_Time_stamp,MLP_Current,MLP_Bias,excise_data_start,excise_data_end,20);


%% Create storage for calculated values and run the algorithim on the collected data

Isat_pred = 3200;
Te_pred = 640;
Vf_pred = 0;

storage(3,21) = 0;
storage(1,1) = Vf_pred;
storage(2,1) = Isat_pred;
storage(3,1) = Te_pred;


% run the algorithim over a number of cycles equal to the 
        for cycle = 1:20
            %calculate isat
            index = cycle*3 - 2;
            I_LP = Current_states(index);
            Isat_pred = First_bias_state(Te_pred, Bias_states(index),I_LP, Vf_pred);
            storage(4,cycle+1) = I_LP;
            
            %calculate Te
            index = cycle*3 - 1;
            I_LP = Current_states(index);
            Te_pred = Second_bias_state(Vf_pred, I_LP, Isat_pred,Bias_states(index));
            storage(5,cycle+1) = I_LP;
            
            if Te_pred > 640*2
            Te_pred = 640*2;
            end
            %calculate Vf
            index = cycle*3 ; 
            I_LP = Current_states(index);
            Vf_pred = Third_bias_state(Te_pred, I_LP, Isat_pred,Bias_states(index) );
            storage(1,cycle+1) = Vf_pred;
            storage(2,cycle+1) = Isat_pred;
            storage(3,cycle+1) = Te_pred;
            storage(6,cycle+1) = I_LP;
        end




storage(1,:) = storage(1,:)./32/2;
storage(2,:) = storage(2,:)./32/100;
storage(3,:) = storage(3,:)./16/4;









