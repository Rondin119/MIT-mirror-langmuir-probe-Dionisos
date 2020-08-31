clear Calc_array volt_array
cd Data
try
data = csvread('MLP_test_data_Shot_5_temps.csv',1,1);
Calc_array(:,1) = data(:,2)*32;
Calc_array(:,2) = data(:,1)*16;
Calc_array(:,3) = circshift(data(:,3),-1)*32;

Calc_array(:,1) = data(:,2)/100;
Calc_array(:,2) = data(:,1)/4;
Calc_array(:,3) = circshift(data(:,3),-1)/2;

Data = csvread('MLP_test_data_Shot_5.csv',1,0);
MLP_Time_stamp = Data(:,1)+eps;
MLP_Current = Data(:,2)./1600+eps;
MLP_Bias = Data(:,3)./32+eps;
volt_array(:,1) = MLP_Bias;
volt_array(:,2) = MLP_Current;
cd ../
catch ME
   cd ../ 
end