%% Initialisation of variables:
% testData.Properties.VariableNames{11} = 'IMU_1';
% testData.Properties.VariableNames{13} = 'X_Axis';

xtestData_array = table2array(testData(:,2:5));
xtestData_array = [xtestData_array testData.X_Axis];
xmean_array = mean(xtestData_array(1:70,:));
xrange_array = max(xtestData_array) - min(xtestData_array);

lenX = length(xtestData_array);
Ax_shift = zeros(lenX,4);
Ax_norm = zeros(lenX,4);
X_Axis_norm = zeros(lenX,1);

for i = 1:4
    Ax_shift(:,i) = xtestData_array(:,i) - xmean_array(i);
    Ax_norm(:,i) = (xtestData_array(:,i) - xmean_array(i))/(xrange_array(i));
end

X_Axis_norm = (xtestData_array(:,5) - xmean_array(5))/(xrange_array(5));

raw_norm = Ax_norm;
raw_shift = Ax_shift;

%% Filtering (Lowpass filter):

FIR_filt = designfilt('lowpassfir','FilterOrder',50,...
    'CutoffFrequency',10,...
    'PassbandRipple',0.001,...
    'SampleRate', 100);

IIR_filt = designfilt('lowpassiir','FilterOrder',2,...
    'PassbandFrequency', 10,...
    'PassbandRipple', 0.001,...
    'SampleRate', 1000);

filt_norm = filter(IIR_filt,raw_norm);
filt_shift = filter(IIR_filt,raw_shift);
filt_IMU1 = filter(IIR_filt,testData.IMU_1);
X_Axis_FN = filter(IIR_filt, X_Axis_norm);

testData(:,{'Shift_A1','Shift_A2','Shift_A3','Shift_A4'}) = array2table(raw_shift(1:lenX,:));
testData(:,{'Norm_A1','Norm_A2','Norm_A3','Norm_A4'}) = array2table(raw_norm(1:lenX,:));
testData(:,{'Filt_A1','Filt_A2','Filt_A3','Filt_A4'}) = array2table(filt_shift(1:lenX,:));
testData(:,{'FN_A1','FN_A2','FN_A3','FN_A4'}) = array2table(filt_norm(1:lenX,:));
testData.IMU_X = filt_IMU1;
testData.X_Axis_norm = X_Axis_FN;

%% Plotting filtered variables:

figure (10)
subplot(2,1,1);
plot(raw_shift(1:lenX,:),'k-');
hold on;
plot(filt_shift(1:lenX,:),'r-','LineWidth',1);
hold off;
% xlim([100 390]);
title('Individual taxel response: Baseline shifted','color',[0 0 1])
grid on;

subplot(2,1,2);
plot(X_Axis_norm(1:lenX),'k-');
hold on;
plot(X_Axis_FN(1:lenX),'r-','LineWidth',1);
hold off;
% xlim([100 390]);
title('Normalised X-axis angles','color',[0 0 1])
grid on;
mtit('Testing Data','fontsize',14,'color',[0 0 0],'xoff',0,'yoff',.04);

%% Regression Predictor setup:

Lin_Models = [trainedModel1, trainedModel2, trainedModel3, trainedModel4];
Tree_Models = [trainedModel5, trainedModel6, trainedModel7];
SVM_Models = [trainedModel8, trainedModel9, trainedModel10,...
    trainedModel11, trainedModel12, trainedModel13];
Ens_Models = [trainedModel14, trainedModel15];
GPR_Models = [trainedModel16, trainedModel17, trainedModel18, trainedModel19];

total_models = [0 length(Lin_Models) length(Tree_Models) length(SVM_Models) length(Ens_Models) length(GPR_Models)];
CS = cumsum(total_models);

for i = 1: CS(end)
    if (i <= CS(2))
        xPrediction(:,i) = Lin_Models(i - CS(1)).predictFcn(testData);
    elseif (i <= CS(3))
        xPrediction(:,i) = Tree_Models(i - CS(2)).predictFcn(testData);
    elseif (i <= CS(4))
        xPrediction(:,i) = SVM_Models(i - CS(3)).predictFcn(testData);
    elseif (i <= CS(5))
        xPrediction(:,i) = Ens_Models(i - CS(4)).predictFcn(testData);
    else
        xPrediction(:,i) = GPR_Models(i - CS(5)).predictFcn(testData);
    end
end

xActual = testData.IMU_X;

%%
Full_Title_names = ["Linear","Interactions Linear","Robust Linear","Stepwise Linear",...
    "Fine Tree", "Medium Tree", "Coarse Tree",...
    "Linear SVM", "Quadratic SVM", "Cubic SVM",...
    "Fine Gaussian SVM","Medium Gaussian SVM","Coarse Gaussian SVM",...
    "Boosted Trees", "Bagged Trees",...
    "Squared Exponential GPR","Matern 5/2 GPR","Exponential GPR","Rational Quadratic GPR",]';

Title_names = ["Linear","Interactions Linear","Robust Linear","Stepwise Linear",...
    "Fine Tree", "Medium Tree", "Coarse Tree",...
    "Linear", "Quadratic", "Cubic",...
    "Fine Gaussian","Medium Gaussian","Coarse Gaussian",...
    "Boosted Trees", "Bagged Trees",...
    "Squared Exp","Matern 5/2","Exponential","Rational Quadratic",]';

start = 60;
stop = 390;

a = round(sqrt(CS(end)));
b = ceil(sqrt(CS(end)));

figure(9);
for i = 1:5
    gca = subplot(2,3,i);
    plot(testData.Time(start:stop),xActual(start:stop,1),'-.');
    hold on;
    plot(testData.Time(start:stop),xPrediction(start:stop,(CS(i)+1):CS(i+1)),'-','LineWidth',1);
    hold off;
    xlim([10 80]);
%     ylim([-180 180]);
    grid on;
    xlabel('Time (s)');
    ylabel('Sensor response');
    title(Title_group_names(i) + " models");
    Local_title = ["Actual";  Title_names(CS(i)+1:CS(i+1))];
    legend(Local_title,'location','SouthWest','FontSize',5.5);
end
subplot(2,3,6);
plot(testData.Time(start:stop),xActual(start:stop,1),'-.','LineWidth',1.5);
hold on;
plot(testData.Time(start:stop),xPrediction(start:stop,:),'-','LineWidth',0.5);
hold off;
xlim([10 80]);
% ylim([-180 180]);
grid on;
xlabel('Time (s)');
ylabel('Sensor response');
title("All models");
mtit('Model Predictions - Grouped','fontsize',14,'color',[0 0 0],'xoff',0,'yoff',0.04);

%%
figure(8);
for i = 1:CS(end)
    subplot(b,a,i);
    plot(testData.Time(start:stop),xActual(start:stop,1),'r-','LineWidth',1.5);
    hold on;
    plot(testData.Time(start:stop),testData.X_Axis(start:stop),'b','LineWidth',1);
    plot(testData.Time(start:stop),xPrediction(start:stop,i),'k','LineWidth',0.5);
    hold off;
    xlim([10 80]);
    grid on;
    title(Full_Title_names(i));
    % xlabel('Time (s)');
    % ylabel('Sensor response');
end
legend({"Actual","Analytical","Prediction"},'location','best');
mtit('Model Predictions - Individual','fontsize',14,'color',[0 0 0],'xoff',0,'yoff',0.04);
