clear all
cd Data
data = csvread('MLP_test_data_Shot_5.csv',1,1);
cd ../
LB_V = data(:,2)*4;
PC = data(:,1)*4;

PC(1)=[];
LB_V(1) = [];




for i =1:length(PC)/6
    if i == 1
        LB_to_write(i) = int64(mean(LB_V(1:6)));
        PC_to_write(i) = int64(mean(PC(1:6)));
    else
        ind = (i-1)*6+1;
        LB_to_write(i) = int64(mean(LB_V(ind:ind+5)));
        PC_to_write(i) = int64(mean(PC(ind:ind+5)));
    end
    
    
end
LB_to_write = LB_to_write';
PC_to_write = PC_to_write';

formatSpec1 = 'LB_Voltage <= std_logic_vector(to_signed(%i,LB_Voltage''length));\n';
formatSpec2 = 'LP_current <= std_logic_vector(to_signed(%i,LB_Voltage''length));\n';

delete check.txt
fileID = fopen('check.txt','w');

for i = 1:15
    fprintf(fileID,formatSpec1,LB_to_write(i));
    fprintf(fileID,formatSpec2,PC_to_write(i));    
    fprintf(fileID,'wait for adc_clk_period*51;\n');
    
    
    
    
    
end











