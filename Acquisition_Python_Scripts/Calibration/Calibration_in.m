clear all
scope_data = csvread('TEK0001.CSV',0,3);
scope_time_raw = scope_data(:,1);
scope_signal_raw = scope_data(:,2);

Bias_or_Current = 'Current'

Data = csvread('MLP_test_data_Shot_1_cal.csv',1,0);
Time_stamp = Data(:,1)+eps;
Current = Data(:,2)*2+eps;
Bias = Data(:,3)*2+eps;

%Fixing the time stamp to not be cyclic
j = 0;
for i = 2:length(Time_stamp)

    if Time_stamp(i-1)>Time_stamp(i)
    j=j+1;
    end
int_mult(i) = j;    

end

for i = 1:length(Time_stamp)
Time_stamp(i) = Time_stamp(i)+32*int_mult(i);

end

%% Correcting Overflow from bit number swap for Bias
if strcmp(Bias_or_Current,'Bias')
break_index = [];
i = 1;
while i < length(Bias)-1
   if (Bias(i)<Bias(i+1))&&(abs(Bias(i)-Bias(i+1))>1000) 
    break_index = [break_index i];
    i = i +5;
   elseif (Bias(i)>Bias(i+1))&&(abs(Bias(i)-Bias(i+1))>1000) 
    break_index = [break_index i];
    i = i +5;
   end
       
      i=i+1;
end

break_index_val = Bias(break_index);

for i = 1:length(break_index)
    if break_index_val(i) < 0
        if i == 1
            if mean(Bias(1:break_index(1))) < - 20
                Bias(1:break_index(1)) =  Bias(1:break_index(1)) + 16382;
            end
            if mean(Bias(1:break_index(1))) >  20
                Bias(1:break_index(1)) =  Bias(1:break_index(1)) - 16382;
            end            
            if mean(Bias(break_index(i)+10:break_index(i+1)-10)) >  10
                Bias(break_index(i)+1:break_index(i+1)) =  Bias(break_index(i)+1:break_index(i+1)) - 16382;
            end
        elseif i == length(break_index)
            if mean(Bias(break_index(i-1)+10:break_index(i)-10)) < - 20
                Bias(break_index(i-1)+1:break_index(i)) =  Bias(break_index(i-1)+1:break_index(i)) + 16382;
            end
            break
        else
            if mean(Bias(break_index(i-1)+10:break_index(i)-10)) < - 20
                Bias(break_index(i-1)+1:break_index(i)) =  Bias(break_index(i-1)+1:break_index(i)) + 16382;
            end
            if mean(Bias(break_index(i)+10:break_index(i+1)-10)) >  10
                Bias(break_index(i)+1:break_index(i+1)) =  Bias(break_index(i)+1:break_index(i+1)) - 16382;
            end
            
        end
        
    end
end

Bias = Bias + eps;
Time_stamp = Time_stamp + eps;

for i = 2: length(Bias)-1
   if abs(Bias(i)-Bias(i+1))>100
       Bias(i) = 0;
       Time_stamp(i) = 0;
   end
    
end
if ~isempty(break_index)
Bias(break_index(end)+1:end) = 0;
Bias(1:break_index(1)) = 0;

Time_stamp(break_index(end)+1:end) = 0;
Time_stamp(1:break_index(1)) = 0;
end


Bias = nonzeros(Bias);
%% Converts the time stamp that is currently saved as 5th of a microsecond to microsecond
Time_stamp = nonzeros(Time_stamp)/5;





figure(1)
clf('reset')
hold on
plot(Time_stamp,Bias,'.','color','r')
try
plot(Time_stamp(break_index),break_index_val,'*')
end
end
%% Correcting Overflow from bit number swap for current
if strcmp(Bias_or_Current,'Current')
break_index = [];
i = 1;
while i < length(Current)-1
   if (Current(i)<Current(i+1))&&(abs(Current(i)-Current(i+1))>1000) 
    break_index = [break_index i];
    i = i +5;
   elseif (Current(i)>Current(i+1))&&(abs(Current(i)-Current(i+1))>1000) 
    break_index = [break_index i];
    i = i +5;
   end
       
      i=i+1;
end

break_index_val = Current(break_index);

for i = 1:length(break_index)
    if break_index_val(i) < 0
        if i == 1
            if mean(Current(1:break_index(1))) < - 20
                Current(1:break_index(1)) =  Current(1:break_index(1)) + 16382;
            end
            if mean(Current(1:break_index(1))) >  20
                Current(1:break_index(1)) =  Current(1:break_index(1)) - 16382;
            end            
            if mean(Current(break_index(i)+10:break_index(i+1)-10)) >  10
                Current(break_index(i)+1:break_index(i+1)) =  Current(break_index(i)+1:break_index(i+1)) - 16382;
            end
        elseif i == length(break_index)
            if mean(Current(break_index(i-1)+10:break_index(i)-10)) < - 20
                Current(break_index(i-1)+1:break_index(i)) =  Current(break_index(i-1)+1:break_index(i)) + 16382;
            end
            break
        else
            if mean(Current(break_index(i-1)+10:break_index(i)-10)) < - 20
                Current(break_index(i-1)+1:break_index(i)) =  Current(break_index(i-1)+1:break_index(i)) + 16382;
            end
            if mean(Current(break_index(i)+10:break_index(i+1)-10)) >  10
                Current(break_index(i)+1:break_index(i+1)) =  Current(break_index(i)+1:break_index(i+1)) - 16382;
            end
            
        end
        
    end
end

Current = Current + eps;
Time_stamp = Time_stamp + eps;

for i = 2: length(Current)-1
   if abs(Current(i)-Current(i+1))>100
       Current(i) = 0;
       Time_stamp(i) = 0;
   end
    
end
figure(1)
clf('reset')
hold on
plot(Time_stamp,Current,'.','color','r')

if ~isempty(break_index)
Current(break_index(end)+1:end) = 0;
Current(1:break_index(1)+1) = 0;

Time_stamp(break_index(end)+1:end) = 0;
Time_stamp(1:break_index(1)+1) = 0;
end




Current = nonzeros(Current);
Time_stamp = nonzeros(Time_stamp)/5;





figure(1)
clf('reset')
hold on
plot(Time_stamp,Current,'.','color','r')
try
plot(Time_stamp(break_index),break_index_val,'*')
end

end
%% Correcting the values of current and Bias from Bit to volts
Bias = Bias *.000122;
Current = Current*.000122;





%% making the Scope Signal start at the zero of the time axis
[scope_peaks,peak_indexes_scope]=findpeaks(smooth(scope_signal_raw,30),'MinPeakProminence',.1);
scope_time = scope_time_raw(peak_indexes_scope(1):end)- scope_time_raw(peak_indexes_scope(1));
scope_signal = smooth(scope_signal_raw(peak_indexes_scope(1):end),1);

first_min_scope = min(scope_signal(peak_indexes_scope(1):peak_indexes_scope(2)));
first_min_scope_index = find(scope_signal == first_min_scope);

scope_mean = mean(scope_signal_raw);

%% Making the MLP signal min line up with the scope min
if strcmp(Bias_or_Current,'Bias')
mlp_signal_raw = Bias;
elseif strcmp(Bias_or_Current,'Current')
mlp_signal_raw = Current;
end
[mlp_peaks,peak_indexes_mlp]=findpeaks(smooth(mlp_signal_raw,100),'MinPeakProminence',.1);
mlp_time = (Time_stamp(peak_indexes_mlp(1):end)- Time_stamp(peak_indexes_mlp(1)))*10^-6;
mlp_signal = smooth(mlp_signal_raw(peak_indexes_mlp(1):end),1);


mlp_mean = mean(mlp_signal_raw);

mean_dif = scope_mean - mlp_mean
mean_dif/.000122

mlp_signal_recon = mlp_signal + mean_dif;


mlp_scale = 1;

figure(2)
clf('reset')
hold on
plot(mlp_time,mlp_scale*mlp_signal_recon,'*','color','r')
plot(scope_time,scope_signal,'color','b','LineWidth',2)
legend({'Uncalibrated RP Signal','Scope Signal'},'FontSize',14)
xlabel('time(s)')
ylabel('Signal (V)')
set(gca,'fontsize', 18)



















%  mlp_time= mlp_time./max(mlp_time);
%  scope_cal_time = scope_cal_time./max(scope_cal_time);
% % 
% % [min_scope,min_scope_index] = min(scope_cal_signal);
% % [max_scope,max_scope_index] = max(scope_cal_signal);
% % 
% [min_mlp,min_mlp_index] = min(mlp_cal_signal);
% [max_mlp,max_mlp_index] = max(mlp_cal_signal);
% period_mlp = abs(mlp_cal_time(min_mlp_index) - mlp_cal_time(max_mlp_index));
% period_scope = abs(scope_cal_time(min_scope_index) - scope_cal_time(max_scope_index));
% 
% scope_cal_time = scope_cal_time*period_mlp./period_scope;
% 
% diff_min_times = mlp_cal_time(min_mlp_index) - scope_cal_time(min_scope_index);
% scope_cal_time = scope_cal_time + diff_min_times;
% 
% diff_min = min_mlp - min_scope;
% mlp_cal_signal = mlp_cal_signal - diff_min;
% 
% scope_cal_signal = scope_cal_signal - min_scope;
% mlp_cal_signal = mlp_cal_signal - min_scope;
% 
% 
% 
% max_scope = max(scope_cal_signal);
% max_mlp = max(mlp_cal_signal);
% mlp_cal_signal = mlp_cal_signal*max_scope/max_mlp;
% 
% scale_calibration = max_scope/max_mlp
% 
% figure(2)
% clf('reset')
% hold on
% plot(mlp_cal_time,mlp_cal_signal,'r')
% plot(scope_cal_time,scope_cal_signal,'b')



