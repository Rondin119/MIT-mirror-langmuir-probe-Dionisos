%%
clearvars -except Scope_Time_Fit Scope_Isat_Fit Scope_Float_Fit Scope_Temp_Fit Scope_Bias Scope_Current Scope_Time_stamp


Shot = '5';
Data = csvread(['MLP_test_data_Shot_',Shot,'.csv'],1,0);
MLP_Time_stamp = Data(:,1)+eps;
MLP_Current = (-Data(:,2)./1600+eps);
MLP_Bias = (Data(:,3)./32+eps);

% plot(MLP_Bias,MLP_Current,'*')
% 
% %%

%Find and remove the noise at the start and make sure it is the lowest bias
%state that we start on.

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





% Cut for shot 6
% excise_data_start = [1 1545 3150 4695 6300 7890 9540 11130 12705 14310 15945 17505 19110];
% excise_data_end = [330 2115 3525 5340 6765 8505 9855 11550 13170 14910 16515 17850 19725];

% Cut for shot 7
% excise_data_start = [1 1515 3090 4680 6330 7920 9510 11115 12735 14325 15915 17520 19095];
% excise_data_end = [165 1755 3375 4980 6570 8250 9750 11325 12930 14565 16215 17775 19380];

%Cut for shot 8
% excise_data_start = [1 1290 2880 4515 6105 7695 9330 10905 12495 14100 15705 17295 18900];
% excise_data_end = [270 1890 3420 4980 6615 8190 9810 11445 12960 14595 16230 17760 19455];

%Cut for shot 9
% excise_data_start = [1 32325 66465 98000];
% excise_data_end = [3495 36645 69990 100000];

%Shot 3
% excise_data_start = [1 12183];
% excise_data_end = [45 12195];

% %Shot 11
% excise_data_start = [1 19984];
% excise_data_end = [5475 20000];

% % Shot 16
% excise_data_start = [410950 99993];
% excise_data_end = [41385 100000];

% % Shot 17
% excise_data_start = [99991];
% excise_data_end = [100000];

% Shot 19
a = length(MLP_Bias);


excise_data_start = [a-20];
excise_data_end = [a];


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

% figure(1)
% clf('reset')
% hold on
% plot(MLP_Time_stamp,MLP_Bias,'.')
% set(gca,'ColorOrderIndex',1)
% plot(MLP_Time_stamp,MLP_Bias)
% plot(MLP_Time_stamp,MLP_Current)
% set(gca,'ColorOrderIndex',2)
% plot(MLP_Time_stamp,MLP_Current,'.')

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
    if (diff_1 < .1)&&(diff_2 < .1)&&(diff_3 < .1)
    Bias_states(i) = mean(MLP_Bias(i+1:i+3))+eps;
    Current_states(i) = mean(MLP_Current(i+1:i+3))+eps;
    Clock_cycles_states(i) = mean(Clock_cycles(i+1:i+3))+eps;
    Time_stamp_states(i) = mean(MLP_Time_stamp(i+1:i+3))+eps;
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
b = max(Bias_states(1:3));
if or((Bias_states(1) == a),(Bias_states(1) == b))
    Bias_states(1) = 0;
    Current_states(1) = 0;
    Clock_cycles_states(1) = 0;
    Time_stamp_states(1) = 0;
    if or((Bias_states(2) == a),(Bias_states(2) == b))
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




Bias_array(length(Bias_states)/3,3)=0;
Current_array(length(Bias_states)/3,3)=0;
Clock_array(length(Bias_states)/3,3)=0;
Time_stamp_array(length(Bias_states)/3,3)=0;

for i = 1:(length(Bias_states)/3-1)
    for j =1:3
        Bias_array(i,j) = Bias_states(i*3+j);
        Current_array(i,j) = Current_states(i*3+j);
        Clock_array(i,j) = Clock_cycles_states(i*3+j);
        Time_stamp_array(i,j) = Time_stamp_states(i*3+j);
    end
end
a=1;

for i = 1:(length(Bias_states)/3)
   if Current_array(i,2)> Current_array(i,3)
       Bias_array(i,:) = zeros(1,3);
       Current_array(i,:) = zeros(1,3);
       Clock_array(i,:) = zeros(1,3);
       Time_stamp_array(i,:) = zeros(1,3);
   end
end

l = 0;
i = 1;
while l == 0
    if Bias_array(i,1) == 0
        Bias_array(i,:) = [];
        Current_array(i,:) = [];
        Clock_array(i,:) = [];
        Time_stamp_array(i,:) = [];
    else
        i = i + 1;
    end
if i == size(Bias_array,1)
    l = 1;
end

end





ft = 'a*(-1+exp((x-b)/c))';
Start_points = [2 0 10];



MLP_Temp_Fit(size(Bias_array,1)-1) = 0;
MLP_Float_Fit(size(Bias_array,1)-1) = 0;
MLP_Isat_Fit(size(Bias_array,1)-1) = 0;
MLP_Time_Fit(size(Bias_array,1)-1) = 0;
%%
parfor i = 1:size(Bias_array,1)-1
MLP_Time_Fit(i) = mean(Time_stamp_array(i,:));
f = Current_array(i,:)';
d = Bias_array(i,:)';
[fit1,gof1] = fit(d,f,ft,'Start',Start_points);
coef = coeffvalues(fit1);
MLP_Isat_Fit(1,i) = coef(1);
MLP_Float_Fit(1,i) = coef(2);
MLP_Temp_Fit(1,i) = coef(3);
MLP_Fit_stats(1,i) = gof1;

end
MLP_Time_Fit=MLP_Time_Fit';

for i = 1:size(Bias_array,1)-1
   MLP_Isat_Fit(2,i) =  MLP_Fit_stats(i).rsquare;
   MLP_Isat_Fit(3,i) =  MLP_Fit_stats(i).sse;
   
   MLP_Float_Fit(2,i) =  MLP_Fit_stats(i).rsquare;
   MLP_Float_Fit(3,i) =  MLP_Fit_stats(i).sse;   
   
   MLP_Temp_Fit(2,i) =  MLP_Fit_stats(i).rsquare;
   MLP_Temp_Fit(3,i) =  MLP_Fit_stats(i).sse;     
   
    
end
saveas(fig2,'Bias_states.jpg','jpg')

save(['Shot_',Shot,'_Fit.mat'],'MLP_Float_Fit','MLP_Isat_Fit','MLP_Temp_Fit','MLP_Time_Fit','MLP_Time_stamp','MLP_Bias','MLP_Current')

% Create plots with the fitted values and points

fits_index = randi(length(MLP_Time_Fit),4,1);
%fits_index = [1 1 1 1];



x_curve = (min(min(Bias_array))):.1:(max(max(Bias_array)));
I_V_curve = @(x,T,Is,V) Is*(-1+exp((x-V)/T));

fig3 = figure(3);
clf('reset')
axes1 = axes('Parent',fig3,'Position',[.55,.55,.4,.4]);
hold on
curve = I_V_curve(x_curve,MLP_Temp_Fit(1,fits_index(1)),MLP_Isat_Fit(1,fits_index(1)),MLP_Float_Fit(1,fits_index(1)));
p1 = plot(x_curve,curve);
p2 = plot(Bias_array(fits_index(1),:),Current_array(fits_index(1),:),'*');
%ylim([-.8,.5])
xlabel('Probe Voltage (V)')
ylabel('Probe Current (A*10^{-2})')
str = ['Index: ',num2str(fits_index(1))];
annotation('textbox',[0.55 0.55 0.05 0.1],'string',str,'FitBoxToText','on','LineStyle','none','Units','normalized','FontWeight','bold','FontSize',12)   
set(axes1,'Linewidth',1.5)
set(axes1,'FontWeight','bold')
hold off

axes2 = axes('Parent',fig3,'Position',[.07,.55,.4,.4]);
hold on
curve = I_V_curve(x_curve,MLP_Temp_Fit(1,fits_index(2)),MLP_Isat_Fit(1,fits_index(2)),MLP_Float_Fit(1,fits_index(2)));
p1 = plot(x_curve,curve);
p2 = plot(Bias_array(fits_index(2),:),Current_array(fits_index(2),:),'*');
%ylim([-.8,.5])
xlabel('Probe Voltage (V)')
ylabel('Probe Current (A*10^{-2})')
str = ['Time Index: ',num2str(fits_index(2))];
annotation('textbox',[0.07 0.55 0.05 0.1],'string',str,'FitBoxToText','on','LineStyle','none','Units','normalized','FontWeight','bold','FontSize',12)   
set(axes2,'Linewidth',1.5)
set(axes2,'FontWeight','bold')
hold off

axes3 = axes('Parent',fig3,'Position',[.55,.1,.4,.4]);
hold on
curve = I_V_curve(x_curve,MLP_Temp_Fit(1,fits_index(3)),MLP_Isat_Fit(1,fits_index(3)),MLP_Float_Fit(1,fits_index(3)));
p1 = plot(x_curve,curve);
p2 = plot(Bias_array(fits_index(3),:),Current_array(fits_index(3),:),'*');
%ylim([-.8,.5])
xlabel('Probe Voltage (V)')
ylabel('Probe Current (A*10^{-2})')
str = ['Time Index: ',num2str(fits_index(3))];
annotation('textbox',[0.55 0.11 0.05 0.1],'string',str,'FitBoxToText','on','LineStyle','none','Units','normalized','FontWeight','bold','FontSize',12)   
set(axes3,'Linewidth',1.5)
set(axes3,'FontWeight','bold')
hold off

axes4 = axes('Parent',fig3,'Position',[.07,.1,.4,.4]);
hold on
curve = I_V_curve(x_curve,MLP_Temp_Fit(1,fits_index(4)),MLP_Isat_Fit(1,fits_index(4)),MLP_Float_Fit(1,fits_index(4)));
p1 = plot(x_curve,curve);
p2 = plot(Bias_array(fits_index(4),:),Current_array(fits_index(4),:),'*');
ylim([-.8,.5])
xlabel('Probe Voltage (V)')
ylabel('Probe Current (A*10^{-2})')
str = ['Time Index: ',num2str(fits_index(4))];
annotation('textbox',[0.07 0.11 0.05 0.1],'string',str,'FitBoxToText','on','LineStyle','none','Units','normalized','FontWeight','bold','FontSize',12)   
set(axes4,'Linewidth',1.5)
set(axes4,'FontWeight','bold')
hold off


saveas(fig3,'MLP_fits')


clear p1 p2


