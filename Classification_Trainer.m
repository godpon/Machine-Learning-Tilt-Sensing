%% Assign Labels:
% Hardcode output labels based on experiment information
trainDataX.Label_X(:) = "Rest";
trainDataX.Label_X(326:850) = "Left";
trainDataX.Label_X(961:1460) = "Right";

% % Assigning labels based on IMU sensor data
% for i = 1:lenX
%     tempX = trainDataX.IMU_1(i);
%     tempY = trainDataX.IMU_2(i);
% 
%     if(abs(tempX) < 2.0)    result_x = "Rest";
%     elseif(tempX > 0)       result_x = "Right";
%     else                    result_x = "Left";
%     end
%     
%     if(abs(tempY) < 2.0)    result_y = "Rest";
%     elseif(tempY > 0)       result_y = "Up";
%     else                    result_y = "Down";
%     end
%     
%     trainDataX.Label_X(i) = result_x;
%     trainDataX.Label_Y(i) = result_y;
% end

trainDataX_mean = mean(testData{:,2:5},2);
xDirection = trainDataX.Label_X;
start = 1;
stop = lenX;

figure(1)
gscatter(trainDataX.Time(start:stop),trainDataX.Filt_A1(start:stop),xDirection(start:stop),'rgb','<o>');
hold on;
gscatter(trainDataX.Time(start:stop),trainDataX.Filt_A2(start:stop),xDirection(start:stop),'rgb','<o>');
hold off;
%xlim([-50 60]);
grid on;
title('Data labels');
xlabel('Time');
ylabel('Sensor responses');

%% Train pre-designed Classifier models:

[x_fineTree, VA_xft] = fineTree_trainer(trainDataX(200:end,:));
[x_fineGaussSVM, VA_xfg] = fineGaussSVM_trainer(trainDataX(200:end,:));
[x_fineKNN, VA_xfk] = fineKNN_trainer(trainDataX(200:end,:));
[x_weightedKNN, VA_xwk] = weightedKNN_trainer(trainDataX(200:end,:));

Cats = categorical({'Fine Tree','Fine Gaussian SVM','Fine KNN','Weighted KNN'});
Cats = reordercats(Cats,{'Fine Tree','Fine Gaussian SVM','Fine KNN','Weighted KNN'});
VA = 100*[VA_xft VA_xfg VA_xfk VA_xwk];

cc = [0.7 0.7 0.7];
bar_chart = bar(Cats,VA,(0.3 + 0.05*length(VA)),'FaceColor',cc);
xtips = bar_chart.XData;
ytips = 0.5*min(VA)*ones(length(VA),1);
labels = string(round(bar_chart.YData,2)) + "%";
text(xtips,ytips,labels,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom','color',circshift(cc-0.6,1))

title('Training model accuracies');
ylabel('Percentage accuracy');