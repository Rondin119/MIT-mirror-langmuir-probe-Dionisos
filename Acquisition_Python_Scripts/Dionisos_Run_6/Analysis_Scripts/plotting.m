clear all

Shot = '7';
Shot_name = ['MLP_test_data_Shot_',Shot,'_temps.csv'];

load(['Shot_',Shot,'_Fit.mat'])
Param_data = csvread(Shot_name,1,0);

Time_Stamp_mlp = Param_data(:,1);
Temp_mlp =  Param_data(:,2)./4+eps;
Float_mlp = Param_data(:,4)./2+eps;
Isat_mlp = Param_data(:,3)./50/2+eps;


%Fixing the time stamp to not be cyclic for mlp
j = 0;
for i = 2:length(Time_Stamp_mlp)

    if Time_Stamp_mlp(i-1)>Time_Stamp_mlp(i)
    j=j+1;
    end
    int_mult(i) = j;    

end

for i = 1:length(Time_Stamp_mlp)
Time_Stamp_mlp(i) = Time_Stamp_mlp(i)+32*int_mult(i);

end


%Rescale Time
MLP_Time_Fit_scale = MLP_Time_Fit;
Time_Stamp_mlp = Time_Stamp_mlp/5;


str = 'Shot 4';
%% Plot the Biases recorded on the scope and the RP
fig1 = figure(1);
clf('reset')
hold on


plot(MLP_Time_stamp,MLP_Bias,'r')
plot(MLP_Time_stamp,MLP_Bias,'*','color','r')

box on
set(gcf,'color','w');
ylabel('Bias (V)','FontSize',12)
xlabel('Time (\mus)','FontSize',12)
set(gca,'Linewidth',1.2)
set(gca,'FontWeight','bold')
set(gca,'ticklength',[.02,.1])
%set(gca,'YTick',[0 25 50 75 100 125 150])

annotation('textbox',[0.15 .90 .4 0],'string',str,'FitBoxToText','off','LineStyle','none','Units','normalized','fontsize',12)  
str1 = 'Signals Not triggered at same time. For rough comparison only.'
annotation('textbox',[0.15 .85 .4 0],'string',str1,'FitBoxToText','off','LineStyle','none','Units','normalized','fontsize',12)  
ylim([0 150])
%set(gca,'XTick',[0  2 4 6 8 10 12 14 16 18 20])
set(gca, 'FontSize', 16)
 ylim([-80 60])

legend('Scope Bias','RP Bias','RP Bias points')


%% Plot the Currents recorded by the Scope and the RP
fig2 = figure(2);
clf('reset')
hold on


plot(MLP_Time_stamp,MLP_Current*1000,'r')
plot(MLP_Time_stamp,MLP_Current*1000,'*','color','r')

box on
set(gcf,'color','w');
ylabel('Current (mA)','FontSize',12)
xlabel('Time (\mus)','FontSize',12)
set(gca,'Linewidth',1.2)
set(gca,'FontWeight','bold')
set(gca,'ticklength',[.02,.1])
%set(gca,'YTick',[0 25 50 75 100 125 150])
1
annotation('textbox',[0.15 .90 .4 0],'string',str,'FitBoxToText','off','LineStyle','none','Units','normalized','fontsize',12)  


ylim([0 150])
%set(gca,'XTick',[0  2 4 6 8 10 12 14 16 18 20])
set(gca, 'FontSize', 16)

 ylim([-600 800])

legend('Scope Current','RP Current','RP Current points')

%% Plot temperatures

%Remove bad fits
if 0
    MLP_Temp_Good_Fit(length(MLP_Time_Fit)) = 0;
    MLP_Isat_Good_Fit(length(MLP_Time_Fit)) = 0;
    MLP_Float_Good_Fit(length(MLP_Time_Fit)) = 0;
    MLP_Time_Good_Fit(length(MLP_Time_Fit)) = 0;
    for i= 1:length(MLP_Time_Fit)
        if abs(MLP_Temp_Fit(2,i)-1)<.000000000001
            MLP_Temp_Good_Fit(i)=MLP_Temp_Fit(1,i);
            MLP_Time_Good_Fit(i)=MLP_Time_Fit(i);
            MLP_Isat_Good_Fit(i)=MLP_Isat_Fit(1,i);
            MLP_Float_Good_Fit(i)=MLP_Float_Fit(1,i);
        end
    end
    MLP_Temp_Good_Fit = nonzeros(MLP_Temp_Good_Fit);
    MLP_Time_Good_Fit = nonzeros(MLP_Time_Good_Fit);
    MLP_Isat_Good_Fit = nonzeros(MLP_Isat_Good_Fit);
    MLP_Float_Good_Fit  = nonzeros(MLP_Float_Good_Fit);
    
else
    MLP_Temp_Good_Fit = MLP_Temp_Fit(1,:);
    MLP_Time_Good_Fit = MLP_Time_Fit;
    MLP_Isat_Good_Fit = MLP_Isat_Fit(1,:);
    MLP_Float_Good_Fit = MLP_Float_Fit(1,:);
end

fig3 = figure(3);
clf('reset')
hold on
%plot(Scope_Time_Fit-min(Scope_Time_Fit),Scope_Temp_Fit(1,:),'color','b')
plot(Time_Stamp_mlp,Temp_mlp,'color','g')
plot(MLP_Time_Good_Fit,MLP_Temp_Good_Fit,'color','r')
plot(MLP_Time_Good_Fit,MLP_Temp_Good_Fit,'*','color','r')
%plot(Scope_Time_Fit-min(Scope_Time_Fit),Scope_Temp_Fit(1,:),'*','color','b')
plot(Time_Stamp_mlp,Temp_mlp,'*','color','g')
legend('MLP Temp Calc','MLP Temp Fit')
box on
set(gcf,'color','w');
ylabel('Temp (ev)')
xlabel('Time (\mus)')
set(gca,'Linewidth',1.5)
set(gca,'FontWeight','bold')
set(gca,'ticklength',[.02,.1])
annotation('textbox',[0.15 .90 .4 0],'string',str,'FitBoxToText','off','LineStyle','none','Units','normalized','fontsize',12)   
%set(gca,'XTick',[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19])
%xlim([0 range(Scope_Time_Fit)])
%ylim([0 100])
str1 = 'Signals Not triggered at same time. For rough comparison only. MLP Calc rails at ~25 for entire shot.'
annotation('textbox',[0.15 .85 .4 0],'string',str1,'FitBoxToText','off','LineStyle','none','Units','normalized','fontsize',12)  



fig4 = figure(4);
clf('reset')
hold on
%plot(Scope_Time_Fit-min(Scope_Time_Fit),Scope_Float_Fit(1,:),'color','b')
plot(Time_Stamp_mlp,Float_mlp,'color','g')
plot(MLP_Time_Good_Fit,MLP_Float_Good_Fit,'color','r')
plot(MLP_Time_Good_Fit,MLP_Float_Good_Fit,'*','color','r')
%plot(Scope_Time_Fit-min(Scope_Time_Fit),Scope_Float_Fit(1,:),'*','color','b')
plot(Time_Stamp_mlp,Float_mlp,'*','color','g')
legend('MLP Float Calc','MLP Float Fit')
box on
set(gcf,'color','w');
ylabel('V Float (V)')
xlabel('Time (\mus)')
set(gca,'Linewidth',1.5)
set(gca,'FontWeight','bold')
set(gca,'ticklength',[.02,.1])
annotation('textbox',[0.15 .90 .4 0],'string',str,'FitBoxToText','off','LineStyle','none','Units','normalized','fontsize',12)   
%set(gca,'XTick',[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19])
%xlim([0 range(Scope_Time_Fit)])
%ylim([0 100])


fig5 = figure(5);
clf('reset')
hold on
%plot(Scope_Time_Fit-min(Scope_Time_Fit),Scope_Isat_Fit(1,:),'color','b')
plot(Time_Stamp_mlp,Isat_mlp,'color','g')
plot(MLP_Time_Good_Fit,MLP_Isat_Good_Fit,'color','r')
plot(MLP_Time_Good_Fit,MLP_Isat_Good_Fit,'*','color','r')
%plot(Scope_Time_Fit-min(Scope_Time_Fit),Scope_Isat_Fit(1,:),'*','color','b')
plot(Time_Stamp_mlp,Isat_mlp,'*','color','g')
legend('Scope Isat Fit','MLP Isat Calc','MLP Isat Fit')
box on
set(gcf,'color','w');
ylabel('Isat (A)')
xlabel('Time (\mus)')
set(gca,'Linewidth',1.5)
set(gca,'FontWeight','bold')
set(gca,'ticklength',[.02,.1])
annotation('textbox',[0.15 .90 .4 0],'string',str,'FitBoxToText','off','LineStyle','none','Units','normalized','fontsize',12)   
%set(gca,'XTick',[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19])
%xlim([0 range(Scope_Time_Fit)])
%ylim([0 100])










saveas(fig1,'Bias.jpg','jpg')
saveas(fig2,'Current.jpg','jpg')
saveas(fig3,'Temp','jpg')
saveas(fig4,'Float','jpg')
saveas(fig5,'Isat','jpg')


