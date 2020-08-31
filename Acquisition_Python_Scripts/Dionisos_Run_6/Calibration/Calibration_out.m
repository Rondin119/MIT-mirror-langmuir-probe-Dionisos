clear all
% RP1 Out1 Test1
Bit_in = [-4000 -1000 0 1000 4000];



scope_data = csvread('tek0009CH1.csv',22,0);
scope_time_raw = scope_data(:,1);
scope_signal_raw = scope_data(:,2);





% Adjusst scope voltage for the scope offset
scope_signal_raw = scope_signal_raw;

signal_states(length(scope_signal_raw)) = 0;

i=1;
while i < (length(scope_signal_raw)-500)
    diff_1 = abs(scope_signal_raw(i)-scope_signal_raw(i+1));
    diff_2 = abs(scope_signal_raw(i+1)-scope_signal_raw(i+2));
    diff_3 = abs(scope_signal_raw(i+2)-scope_signal_raw(i+3));
    diff_4 = abs(scope_signal_raw(i+3)-scope_signal_raw(i+4));
    diff_5 = abs(scope_signal_raw(i+4)-scope_signal_raw(i+5));
    diff_6 = abs(scope_signal_raw(i+5)-scope_signal_raw(i+6));
    diff_7 = abs(scope_signal_raw(i+6)-scope_signal_raw(i+7));    
    
    if (diff_1 < .1)&&(diff_2 < .1)&&(diff_3 < .1)&&(diff_4 < .1)&&(diff_5 < .1)&&(diff_6 < .1)&&(diff_7 < .1)
    signal_states(i) = mean(scope_signal_raw(i+1:i+5))+eps;
    i = i + 1100;
    end
    i = i +1;
end
signal_states = nonzeros(signal_states);

figure(1)
clf('reset')
hold on
plot(signal_states,'*')
xlabel('Signal Index')
ylabel('Voltage (v)')
set(gca,'fontsize', 18)












% Convert the bit numbers to voltages 
Volts_expected = Bit_in*0.000122;





x = -1000:1000;
y = @(x) 1.0371*x - 3;

for i=1:length(x)
fitted_line(i) = y(x(i));
end

figure(2)
clf('reset')
hold on
xlabel('Signal Voltage (v)')
ylabel('Expected Voltage (v)')
plot(signal_states(3:7),Volts_expected,'*')
set(gca,'fontsize', 18)















