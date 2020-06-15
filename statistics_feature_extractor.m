%% Initialisation of variables:
xtrainData_array = table2array(trainDataX(:,2:5));
xtrainData_array = [xtrainData_array trainDataX.X_Axis];
xmean_array = mean(xtrainData_array(1:70,:));
xrange_array = max(xtrainData_array) - min(xtrainData_array);
ytrainData_array = table2array(trainDataY(:,2:5));
ytrainData_array = [ytrainData_array trainDataY.Y_Axis];
ymean_array = mean(ytrainData_array(600:670,:));
yrange_array = max(ytrainData_array) - min(ytrainData_array);

lenX = length(xtrainData_array);
lenY = length(ytrainData_array);
Ax_shift = zeros(lenX,4);
Ax_norm = zeros(lenX,4);
Ay_shift = zeros(lenY,4);
Ay_norm = zeros(lenY,4);
X_Axis_norm = zeros(lenX,1);
Y_Axis_norm = zeros(lenY,1);

for i = 1:4
    Ax_shift(:,i) = xtrainData_array(:,i) - xmean_array(i);
    Ax_norm(:,i) = (xtrainData_array(:,i) - xmean_array(i))/(xrange_array(i));
    Ay_shift(:,i) = ytrainData_array(:,i) - ymean_array(i);
    Ay_norm(:,i) = (ytrainData_array(:,i) - ymean_array(i))/(yrange_array(i));
end

X_Axis_norm = (xtrainData_array(:,5) - xmean_array(5))/(xrange_array(5));
Y_Axis_norm = (ytrainData_array(:,5) - ymean_array(5))/(yrange_array(5));

B = zeros(abs(lenY-lenX),4);
if(lenY>lenX)
    Ax_norm = [Ax_norm; B];
    Ax_shift = [Ax_shift; B];
else
    Ay_norm = [Ay_norm; B];
    Ay_shift = [Ay_shift; B];
end

raw_norm = [Ax_norm Ay_norm];
raw_shift = [Ax_shift Ay_shift];

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
filt_IMU1 = filter(IIR_filt,trainDataX.IMU_1);
filt_IMU2 = filter(IIR_filt,trainDataY.IMU_2);
X_Axis_norm = filter(IIR_filt, X_Axis_norm);
Y_Axis_norm = filter(IIR_filt, Y_Axis_norm);

trainDataX(:,{'Shift_A1','Shift_A2','Shift_A3','Shift_A4'}) = array2table(raw_shift(1:lenX,1:4));
trainDataX(:,{'Norm_A1','Norm_A2','Norm_A3','Norm_A4'}) = array2table(raw_norm(1:lenX,1:4));
trainDataX(:,{'Filt_A1','Filt_A2','Filt_A3','Filt_A4'}) = array2table(filt_shift(1:lenX,1:4));
trainDataX(:,{'FN_A1','FN_A2','FN_A3','FN_A4'}) = array2table(filt_norm(1:lenX,1:4));
trainDataY(:,{'Shift_A1','Shift_A2','Shift_A3','Shift_A4'}) = array2table(raw_shift(1:lenY,5:8));
trainDataY(:,{'Norm_A1','Norm_A2','Norm_A3','Norm_A4'}) = array2table(raw_norm(1:lenY,5:8));
trainDataY(:,{'Filt_A1','Filt_A2','Filt_A3','Filt_A4'}) = array2table(filt_shift(1:lenY,5:8));
trainDataY(:,{'FN_A1','FN_A2','FN_A3','FN_A4'}) = array2table(filt_norm(1:lenY,5:8));

trainDataX.IMU_X = filt_IMU1;
trainDataX.IMU_X(1:300) = 0.1*trainDataX.IMU_X(1:300);
trainDataX.X_Axis_norm = X_Axis_norm;

trainDataY.IMU_Y = filt_IMU2;
trainDataY.Y_Axis_norm = Y_Axis_norm;

figure(4)
plot(trainDataX.Time, trainDataX.IMU_1,':');
hold on;
plot(trainDataX.Time, trainDataX.IMU_X);
plot(trainDataX.Time, trainDataX.X_Axis);
plot(trainDataX.Time, 160*trainDataX.X_Axis_norm);
hold off;
grid on;

%% Plotting variables:
figure (1)
subplot(3,2,1)
plot(Ax_shift(1:lenX,:));
title('X-axis: Baseline shifted','color',[0 0 1])
grid on;
subplot(3,2,2)
plot(Ay_shift(1:lenY,:));
title('Y-axis: Baseline shifted','color',[1 0 0])
grid on;
xlim([0 2100]);
subplot(3,2,[3,5])
plot(filt_shift(1:lenX,1:4),'-','LineWidth',1);
hold on;
plot(raw_shift(1:lenX,1:4),'-.');
hold off;
title('X-axis: filtered','color',[0 0 1])
grid on;
subplot(3,2,[4,6])
plot(filt_shift(1:lenY,5:8),'-','LineWidth',1);
hold on;
plot(raw_shift(1:lenY,5:8),'-.');
hold off;
title('Y-axis: filtered','color',[1 0 0])
grid on;
xlim([0 2100]);
mtit('Training Data','fontsize',14,'color',[0 0 0],'xoff',0,'yoff',.03);

% px = [1:2 7:8];
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
%     xlim([0 2100]);
% end
% 
% figure(3)
% subplot(2,1,1)
% plot(Ax_norm(1:lenX,:));
% title('X-axis: Normalized','color',[0 0 1])
% grid on;
% subplot(2,1,2)
% plot(Ay_norm(1:lenY,:));
% title('Y-axis: Normalized','color',[1 0 0])
% xlim([0 2100]);
% grid on;
% 
% % for i = 1:length(px)
% %     subplot(b,a,i);
% %     plot(raw_norm(:,px(i)));
% %     hold on;
% %     plot(filt_norm(:,px(i)));
% %     hold off;
% %     xlim([0 2100]);
% % end
% % 
