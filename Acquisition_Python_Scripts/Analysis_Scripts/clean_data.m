function [Bias_states,Current_states,Clock_cycles_states,Time_stamp_states] = clean_data(MLP_Time_stamp,MLP_Current,MLP_Bias,excise_data_start,excise_data_end,threshold)
%CLEAN_DATA Summary of this function goes here
%   Detailed explanation goes here

%Fixing the time stamp to not be cyclic
j = 0;
for i = 2:length(MLP_Time_stamp)

    if MLP_Time_stamp(i-1)>MLP_Time_stamp(i)
    j=j+1;
    end
int_mult(i) = j;    

end

for i = 1:length(MLP_Time_stamp)
MLP_Time_stamp(i) = MLP_Time_stamp(i)+32*int_mult(i);

end

for i = 1:length(excise_data_start)

    for j = excise_data_start(i):excise_data_end(i)
        MLP_Bias(j) = 0;
    MLP_Current(j) = 0;
MLP_Time_stamp(j) = 0;
    end
    
    
end
MLP_Bias = nonzeros(MLP_Bias);
MLP_Current = nonzeros(MLP_Current);
MLP_Time_stamp = nonzeros(MLP_Time_stamp)/5;



Clock_cycles = 1:length(MLP_Bias);
Bias_states = 0;
Current_states = 0;

figure(1)
clf('reset')
hold on
plot(Clock_cycles,MLP_Bias,'.')
set(gca,'ColorOrderIndex',1)
plot(Clock_cycles,MLP_Bias)
plot(Clock_cycles,MLP_Current)
set(gca,'ColorOrderIndex',2)
plot(Clock_cycles,MLP_Current,'.')






i=1;
while i < (length(MLP_Bias)-9)
    diff_1 = abs(MLP_Bias(i)-MLP_Bias(i+1));
    diff_2 = abs(MLP_Bias(i+1)-MLP_Bias(i+2));
    diff_3 = abs(MLP_Bias(i+2)-MLP_Bias(i+3));
    if (diff_1 < threshold)&&(diff_2 < threshold)&&(diff_3 < threshold)
    Bias_states(i) = mean(MLP_Bias(i+1:i+4))+eps;
    Current_states(i) = mean(MLP_Current(i+1:i+4))+eps;
    Clock_cycles_states(i) = mean(Clock_cycles(i+1:i+4))+eps;
    Time_stamp_states(i) = mean(MLP_Time_stamp(i+1:i+4))+eps;
    i = i + 4;
    end
    i = i +1;
end
Bias_states = nonzeros(Bias_states) ;
Current_states = nonzeros(Current_states);
Clock_cycles_states =nonzeros(Clock_cycles_states);
Time_stamp_states = nonzeros(Time_stamp_states) ;

%Check the cycle to make sure it is starting at the lowest point
%It is necessary to vissually check to make sure the first cycle does not
%have any errors.

Bias_states = Bias_states + eps;
Current_states = Current_states + eps;
Clock_cycles_states = Clock_cycles_states + eps;
Time_stamp_states = Time_stamp_states + eps;

a = min(Bias_states(1:3));
if Bias_states(1) ~= a
    Bias_states(1) = 0;
    Current_states(1) = 0;
    Clock_cycles_states(1) = 0;
    Time_stamp_states(1) = 0;
    if Bias_states(2) ~= a
        Bias_states(2) = 0;
        Current_states(2) = 0;
        Clock_cycles_states(2) = 0;
        Time_stamp_states(2) = 0;
    end
end

Bias_states = nonzeros(Bias_states);
Current_states = nonzeros(Current_states);
Clock_cycles_states = round(nonzeros(Clock_cycles_states));
Time_stamp_states = nonzeros(Time_stamp_states);


fig1=figure(1);
clf('reset')
hold on
plot(MLP_Time_stamp,MLP_Bias,'.')
set(gca,'ColorOrderIndex',1)
plot(MLP_Time_stamp,MLP_Bias)
%plot(Clock_cycles,Current)
set(gca,'ColorOrderIndex',3)
%plot(Time_stamp,Current,'.')
plot(Time_stamp_states,Bias_states,'*')
%plot(Clock_cycles_states,Current_states,'*')
xlabel('Clock Cycles')
ylabel('Bias (Bit Number)')
set(gca, 'FontSize', 14)

fig2=figure(2)
clf('reset')
hold on
plot(Clock_cycles,MLP_Bias,'.')
set(gca,'ColorOrderIndex',1)
plot(Clock_cycles,MLP_Bias)
plot(Clock_cycles,MLP_Current)
set(gca,'ColorOrderIndex',2)
plot(Clock_cycles,MLP_Current,'.')
plot(Clock_cycles_states,Bias_states,'*')
plot(Clock_cycles_states,Current_states,'*')
xlabel('ticks')
ylabel('Bias (V)')






end

