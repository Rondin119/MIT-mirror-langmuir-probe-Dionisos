
clearvars -except Scope_Time_Fit Scope_Isat_Fit Scope_Float_Fit Scope_Temp_Fit Scope_Bias Scope_Current Scope_Time_stamp

cd Data
Data = csvread('MLP_test_data_Shot_11.csv',1,0);
cd ../
MLP_Time_stamp = Data(:,1)+eps;
MLP_Current = Data(:,2)./1600+eps;
MLP_Bias = Data(:,3)./32+eps;



%Find and remove the noise at the start and make sure it is the lowest bias
%state that we start on.

% Shot 19
excise_data_start = [];
excise_data_end = [];

[Bias_states,Current_states,Clock_cycles_states,Time_stamp_states] = clean_data(MLP_Time_stamp,MLP_Current,MLP_Bias,excise_data_start,excise_data_end,2);

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
   if Current_array(i,2)< Current_array(i,3)
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

parfor (i = 1:size(Bias_array,1)-1,4)
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


