%% Initialisation of variables:
xtestData_array = table2array(testData(:,2:5));
xmean_array = mean(xtestData_array(1:70,:));
xrange_array = max(xtestData_array) - min(xtestData_array);
testData.Properties.VariableNames{11} = 'IMU_1';

lenX = length(xtestData_array);
Ax_shift = zeros(lenX,4);
Ax_norm = zeros(lenX,4);

for i = 1:4
    Ax_shift(:,i) = xtestData_array(:,i) - xmean_array(i);
    Ax_norm(:,i) = (xtestData_array(:,i) - xmean_array(i))/(xrange_array(i));
end

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

testData(:,{'Shift_A1','Shift_A2','Shift_A3','Shift_A4'}) = array2table(raw_shift(1:lenX,:));
testData(:,{'Norm_A1','Norm_A2','Norm_A3','Norm_A4'}) = array2table(raw_norm(1:lenX,:));
testData(:,{'Filt_A1','Filt_A2','Filt_A3','Filt_A4'}) = array2table(filt_shift(1:lenX,:));
testData(:,{'FN_A1','FN_A2','FN_A3','FN_A4'}) = array2table(filt_norm(1:lenX,:));
testData.IMU_X = filt_IMU1;

%% Plotting variables:
figure (1)
plot(raw_shift(1:lenX,:),'k-');
hold on;
plot(filt_shift(1:lenX,:),'r-','LineWidth',1);
hold off;
% xlim([100 390]);
title('X-axis: Baseline shifted','color',[0 0 1])
grid on;
mtit('Testing Data','fontsize',14,'color',[0 0 0],'xoff',0,'yoff',.03);

% px = [1:4];
% a = round(sqrt(length(px)));
% b = ceil(sqrt(length(px)));
% 
% figure(2)
% for i = 1:length(px)
%     subplot(b,a,i);
%     plot(raw_shift(:,px(i)),'-.');
%     hold on;
%     plot(filt_shift(:,px(i)));
%     hold off;
%     grid on;
%     xlim([0 1600]);
% end
% 
% figure(3)
% for i = 1:length(px)
%     subplot(b,a,i);
%     plot(raw_norm(:,px(i)));
%     hold on;
%     plot(filt_norm(:,px(i)));
%     hold off;
%     grid on;
%     xlim([0 1600]);
% end

%% Classification Predictor setup:
xPred_fTree = x_fineTree.predictFcn(testData);
xPred_fgSVM = x_fineGaussSVM.predictFcn(testData);
xPred_fKNN = x_fineKNN.predictFcn(testData);
xPred_wKNN = x_weightedKNN.predictFcn(testData);
xActual = testData.Label_X;
xDirection = [xActual xPred_fTree xPred_fgSVM xPred_fKNN xPred_wKNN];
%xDirection = [xActual xPred_fTree xPred_wKNN];
Title_names = ["Actual","fTree","fgSVM","fKNN","wKNN"];
%Title_names = ["Actual","fTree","wKNN"];

start = 60;
stop = 390;

testData_mean = mean(testData{:,2:5},2);

figure(4);
for i = 1:5
    subplot(2,3,i);
    gscatter(testData.IMU_X(start:stop),testData_mean(start:stop),xDirection(start:stop,i),'rgb','<o>');
    %xlim([-50 60]);
    grid on;
    title(Title_names(i));
    xlabel('IMU response');
    ylabel('Sensor response');
end

subplot(2,3,[6]);
plot(testData.Time(start:stop),xDirection(start:stop,:),'LineWidth',1.5);
legend(Title_names,'location','best');
xlim([10 80]);
grid on;
title('Time series');
xlabel('Time (s)');
ylabel('Classes');
