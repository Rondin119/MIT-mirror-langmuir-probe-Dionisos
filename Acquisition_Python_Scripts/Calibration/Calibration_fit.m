clear all
fast = 1;
scope_data = csvread('scopeData1.csv',2,0);
scope_time_raw = scope_data(:,1);
scope_signal_raw = scope_data(:,3);

%if using RP as scopscope_time_rawe
for i = 1:length(scope_time_raw)
    if abs(scope_time_raw(i))>25.1
        scope_time_raw(i) = scope_time_raw(i)/1000;
    end
end
scope_time_raw = flipud((scope_time_raw - min(scope_time_raw)))/1000;
scope_signal_raw = flipud(scope_signal_raw) *100/1000*1.1;
Bias_or_Current = 'Current'



Data = csvread('MLP_test_data_Shot_1_Cal.csv',1,0);
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
[scope_peaks,peak_indexes_scope]=findpeaks(smooth(scope_signal_raw),'MinPeakProminence',.1);
scope_time = scope_time_raw(peak_indexes_scope(1):end)- scope_time_raw(peak_indexes_scope(1));
scope_signal = smooth(scope_signal_raw(peak_indexes_scope(1):end),1);

first_min_scope = min(scope_signal(peak_indexes_scope(1):peak_indexes_scope(2)));
first_min_scope_index = find(scope_signal == first_min_scope);

scope_mean = mean(scope_signal_raw);
if fast == 1
scope_parm = fit1(scope_time_raw,scope_signal_raw,3);
else
scope_parm = fit(scope_time_raw,scope_signal_raw,3);
end
%% Making the MLP signal min line up with the scope min
if strcmp(Bias_or_Current,'Bias')
mlp_signal_raw = Bias;
elseif strcmp(Bias_or_Current,'Current')
mlp_signal_raw = Current;
end
[mlp_peaks,peak_indexes_mlp]=findpeaks(smooth(mlp_signal_raw,100),'MinPeakProminence',.1);
mlp_time = (Time_stamp(peak_indexes_mlp(1):end)- Time_stamp(peak_indexes_mlp(1)))*10^-6;
mlp_signal = smooth(mlp_signal_raw(peak_indexes_mlp(1):end));

if fast==1
mlp_parm = fit1(Time_stamp(1:150:length(Time_stamp))*10^-6,mlp_signal_raw(1:150:length(mlp_signal_raw)),4);
else
mlp_parm = fit(Time_stamp(1:150:length(Time_stamp))*10^-6,mlp_signal_raw(1:150:length(mlp_signal_raw)),4);   
end

f = @(x) mlp_parm.a*cos(mlp_parm.b*x+mlp_parm.d)+mlp_parm.c;
y_plt = f(Time_stamp*10^-6);
figure(5)
clf('reset')
plot(Time_stamp*10^-6,mlp_signal_raw,'r')
hold on
plot(Time_stamp*10^-6,y_plt,'b')
legend('raw','fit')


mlp_mean = mean(mlp_signal_raw);

mean_dif = (scope_mean - mlp_mean);
mean_diff_bit = (scope_mean - mlp_mean)/.000122;


%due to a poor choice that ted pointed out I am doing this backwards so to
%find the offset I must apply the scale I calculate.
mlp_scale_fit = scope_parm.a/mlp_parm.a
mean_diff_fit = (scope_parm.c - mlp_scale_fit*mlp_parm.c)/.000122


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



%% Helper functions


function [chi_S] = cos_chi(x,y,a,b,c,d)
f = @(x) a*cos(b*x+d)+c;
y_f = f(x);
chis = (y - y_f).^2;
chi_S = sum(chis);

end


function [parm] = fit(x,y,fig_num)

chi = 100000;
a_list = (.4:.01:.6);
b = 6283.18;
c_list = -.03:.001:03;
d_list = 0:3.14159/100:3.14159*2;
my_chi(length(a_list),length(c_list),length(d_list)) = 100;
for a = 1:length(a_list)
    for c = 1:length(c_list)
        for d = 1:length(d_list)
            my_chi(a,c,d) = cos_chi(x,y,a_list(a),b,c_list(c),d_list(d));
        end
        
    end
    disp(['a = ',num2str(a)])
end

[v,loc] = min(my_chi(:));
[ii,jj,k] = ind2sub(size(my_chi),loc);

parm.a = a_list(ii);
parm.b = b;
parm.c = c_list(jj);
parm.d = d_list(k);

f = @(x) parm.a*cos(parm.b*x+parm.d)+parm.c;
y_plt = f(x);
figure(fig_num)
clf('reset')
plot(x,y,'r')
hold on
plot(x,y_plt,'b')
legend('raw','fit')


end

function [parm] = fit1(x,y,fig_num)

chi = 100000;


b = 6283.18;
d_list = 0:3.14159/100:3.14159*2;
my_chi_d(length(d_list)) = 100;
a = .5;
c = 0;
for d = 1:length(d_list)
    my_chi_d(d) = cos_chi(x,y,a,b,c,d_list(d));
end

[aa,ind] = min(my_chi_d);
d = d_list(ind);


a_list = (.4:.005:.6);
c_list = -.03:.00005:03;



my_chi(length(a_list),length(c_list)) = 100;
for a = 1:length(a_list)
    for c = 1:length(c_list)
my_chi(a,c) = cos_chi(x,y,a_list(a),b,c_list(c),d);   
    end
    disp(['a = ',num2str(a)])
end

[v,loc] = min(my_chi(:));
[ii,jj] = ind2sub(size(my_chi),loc);

parm.a = a_list(ii);
parm.b = b;
parm.c = c_list(jj);
parm.d = d;

f = @(x) parm.a*cos(parm.b*x+parm.d)+parm.c;
y_plt = f(x);
figure(fig_num)
clf('reset')
plot(x,y,'r')
hold on
plot(x,y_plt,'b')
legend('raw','fit')


end



