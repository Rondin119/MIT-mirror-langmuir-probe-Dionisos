clearvars -except MLP_Time_Fit MLP_Isat_Fit MLP_Float_Fit MLP_Temp_Fit MLP_Bias MLP_Current MLP_Time_stamp
CSV_file_name = 'tek0026ALL.csv';

Data = csvread(CSV_file_name,21,0);
Scope_Time_stamp = Data(:,1)*10^6+eps;
Scope_Current = 2*Data(:,4)+eps;
Scope_Bias = -Data(:,3)*100+eps;
Scope_Bias_Request = Data(:,2)*100+eps;



%Find and remove the noise at the start and make sure it is the lowest bias
%state that we start on.



 
%Shot 17
 excise_data_start = [0];
 excise_data_end = [0]; 
 
for i = 1:length(excise_data_start)

    for j = excise_data_start(i):excise_data_end(i)
        Scope_Bias(j) = 0;
        Scope_Current(j) = 0;
        Scope_Time_stamp(j) = 0;
        Scope_Bias_Request(j) = 0;
    end
    
    
end
Scope_Bias = nonzeros(Scope_Bias);
Scope_Current = nonzeros(Scope_Current);
Scope_Time_stamp = nonzeros(Scope_Time_stamp);
Scope_Bias_Request = nonzeros(Scope_Bias_Request);


Bias_states = 0;
Current_states = 0;

figure(1)
clf('reset')
hold on
plot(Scope_Time_stamp,Scope_Bias,'.')
set(gca,'ColorOrderIndex',1)
plot(Scope_Time_stamp,Scope_Bias)
plot(Scope_Time_stamp,Scope_Current)
set(gca,'ColorOrderIndex',2)
plot(Scope_Time_stamp,Scope_Current,'.')


i=1;
while i < (length(Scope_Bias)-60)
    diff_1 = abs(Scope_Bias(i)-Scope_Bias(i+1));
    diff_2 = abs(Scope_Bias(i+1)-Scope_Bias(i+2));
     diff_3 = abs(Scope_Bias(i+2)-Scope_Bias(i+3));
     diff_4 = abs(Scope_Bias(i+3)-Scope_Bias(i+4));
     diff_5 = abs(Scope_Bias(i+4)-Scope_Bias(i+5));
     diff_6 = abs(Scope_Bias(i+5)-Scope_Bias(i+6));
     diff_7 = abs(Scope_Bias(i+6)-Scope_Bias(i+7));
    
    if (diff_1 < 15)&&(diff_2 < 15)&&(diff_3 < 15)&&(diff_4 < 15)&&(diff_5 < 15)&&(diff_6 < 15)&&(diff_7 < 15)
    Bias_states(i) = mean(Scope_Bias(i+1:i+10))+eps;
    Current_states(i) = mean(Scope_Current(i+2:i+10))+eps;
    Time_stamp_states(i) = mean(Scope_Time_stamp(i+1:i+10))+eps;
    
    i = i + 235;
    end
    i = i +1;
end



%Check the cycle to make sure it is starting at the lowest point
%It is necessary to vissually check to make sure the first cycle does not
%have any errors.

a = min(Bias_states(1:3));
if Bias_states(1) ~= a
    Bias_states(1) = 0;
    Current_states(1) = 0;
    Time_stamp_states(1) = 0;
    if Bias_states(2) ~= a
        Bias_states(2) = 0;
        Current_states(2) = 0;
        Time_stamp_states(2) = 0;
    end
end

Bias_states = nonzeros(Bias_states);
Current_states = nonzeros(Current_states);
Time_stamp_states = nonzeros(Time_stamp_states);






figure(1)
clf('reset')
hold on
plot(Scope_Time_stamp,Scope_Bias,'.')
set(gca,'ColorOrderIndex',1)
plot(Scope_Time_stamp,Scope_Bias)
plot(Scope_Time_stamp,Scope_Current)
set(gca,'ColorOrderIndex',2)
plot(Scope_Time_stamp,Scope_Current,'.')
plot(Time_stamp_states,Bias_states,'*')
plot(Time_stamp_states,Current_states,'*')
ylabel('Bias(V),Current(A)')
xlabel('\mus')




Bias_array(length(Bias_states)/3,3)=0;
Current_array(length(Bias_states)/3,3)=0;
Clock_array(length(Bias_states)/3,3)=0;
Time_stamp_array(length(Bias_states)/3,3)=0;

for i = 1:(length(Bias_states)/3-1)
    for j =1:3
        Bias_array(i,j) = Bias_states(i*3+j);
        Current_array(i,j) = Current_states(i*3+j);
        Time_stamp_array(i,j) = Time_stamp_states(i*3+j);
    end
end


for i = 1:(length(Bias_states)/3-1)
   if Current_array(i,2)> Current_array(i,3)
       Bias_array(i,:) = zeros(1,3);
       Current_array(i,:) = zeros(1,3);
       Time_stamp_array(i,:) = zeros(1,3);
   end
end

l = 0;
i = 1;
while l == 0
    if Bias_array(i,1) == 0
        Bias_array(i,:) = [];
        Current_array(i,:) = [];
        Time_stamp_array(i,:)= [];
    else
        i = i + 1;
    end
if i == size(Bias_array,1)
    l = 1;
end

end





ft = 'a*(-1+exp((x-b)/c))';
Start_points = [2 0 75];



Scope_Temp_Fit(size(Bias_array,1)-1) = 0;
Scope_Float_Fit(size(Bias_array,1)-1) = 0;
Scope_Isat_Fit(size(Bias_array,1)-1) = 0;
Scope_Time_Fit(size(Bias_array,1)-1) = 0;

parfor i = 1:size(Bias_array,1)-1
Scope_Time_Fit(i) = mean(Time_stamp_array(i,:));
f = Current_array(i,:)';
d = Bias_array(i,:)';
[fit1,gof1] = fit(d,f,ft,'Start',Start_points);
coef = coeffvalues(fit1);
Scope_Isat_Fit(1,i) = coef(1);
Scope_Float_Fit(1,i) = coef(2);
Scope_Temp_Fit(1,i) = coef(3);
Scope_Fit_stats(1,i) = gof1;

end
Scope_Time_Fit = Scope_Time_Fit';


for i = 1:size(Bias_array,1)-1
   Scope_Isat_Fit(2,i) =  Scope_Fit_stats(i).rsquare;
   Scope_Isat_Fit(3,i) =  Scope_Fit_stats(i).sse;
   
   Scope_Float_Fit(2,i) =  Scope_Fit_stats(i).rsquare;
   Scope_Float_Fit(3,i) =  Scope_Fit_stats(i).sse;   
   
   Scope_Temp_Fit(2,i) =  Scope_Fit_stats(i).rsquare;
   Scope_Temp_Fit(3,i) =  Scope_Fit_stats(i).sse;     
   
    
end









% Create plots with the fitted values and points

fits_index = randi(length(Scope_Temp_Fit),4,1);
%fits_index = [1 1 1 1];



x_curve = (min(min(Bias_array))):.1:(max(max(Bias_array)));
I_V_curve = @(x,T,Is,V) Is*(-1+exp((x-V)/T));

fig3 = figure(3);
clf('reset')
axes1 = axes('Parent',fig3,'Position',[.55,.55,.4,.4]);
hold on
curve = I_V_curve(x_curve,Scope_Temp_Fit(1,fits_index(1)),Scope_Isat_Fit(1,fits_index(1)),Scope_Float_Fit(1,fits_index(1)));
p1 = plot(x_curve,curve);
p2 = plot(Bias_array(fits_index(1),:),Current_array(fits_index(1),:),'*');
%ylim([-.8,.5])
xlabel('Probe Voltage (V)')
ylabel('Probe Current (A*10^{-2})')
str = ['Time Index: ',num2str(fits_index(1))];
annotation('textbox',[0.55 0.55 0.05 0.1],'string',str,'FitBoxToText','on','LineStyle','none','Units','normalized','FontWeight','bold','FontSize',12)   
set(axes1,'Linewidth',1.5)
set(axes1,'FontWeight','bold')
hold off

axes2 = axes('Parent',fig3,'Position',[.07,.55,.4,.4]);
hold on
curve = I_V_curve(x_curve,Scope_Temp_Fit(1,fits_index(2)),Scope_Isat_Fit(1,fits_index(2)),Scope_Float_Fit(1,fits_index(2)));
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
curve = I_V_curve(x_curve,Scope_Temp_Fit(1,fits_index(3)),Scope_Isat_Fit(1,fits_index(3)),Scope_Float_Fit(1,fits_index(3)));
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
curve = I_V_curve(x_curve,Scope_Temp_Fit(1,fits_index(4)),Scope_Isat_Fit(1,fits_index(4)),Scope_Float_Fit(1,fits_index(4)));
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

clear Scope_Fit_stats p1 p2