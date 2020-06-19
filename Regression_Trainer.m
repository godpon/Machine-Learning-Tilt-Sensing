%% Train pre-designed Regression models:

start = 200;
stop = height(trainDataX);
RMSE = zeros(1,19);

[trainedModel1, RMSE(1)] = trainRegressionModel1(trainDataX(start:stop,:));
[trainedModel2, RMSE(2)] = trainRegressionModel2(trainDataX(200:end,:));
[trainedModel3, RMSE(3)] = trainRegressionModel3(trainDataX(200:end,:));
[trainedModel4, RMSE(4)] = trainRegressionModel4(trainDataX(200:end,:));
[trainedModel5, RMSE(5)] = trainRegressionModel5(trainDataX(200:end,:));
[trainedModel6, RMSE(6)] = trainRegressionModel6(trainDataX(200:end,:));
[trainedModel7, RMSE(7)] = trainRegressionModel7(trainDataX(200:end,:));
[trainedModel8, RMSE(8)] = trainRegressionModel8(trainDataX(200:end,:));
[trainedModel9, RMSE(9)] = trainRegressionModel9(trainDataX(200:end,:));
[trainedModel10, RMSE(10)] = trainRegressionModel10(trainDataX(200:end,:));
[trainedModel11, RMSE(11)] = trainRegressionModel11(trainDataX(200:end,:));
[trainedModel12, RMSE(12)] = trainRegressionModel12(trainDataX(200:end,:));
[trainedModel13, RMSE(13)] = trainRegressionModel13(trainDataX(200:end,:));
[trainedModel14, RMSE(14)] = trainRegressionModel14(trainDataX(200:end,:));
[trainedModel15, RMSE(15)] = trainRegressionModel15(trainDataX(200:end,:));
[trainedModel16, RMSE(16)] = trainRegressionModel16(trainDataX(200:end,:));
[trainedModel17, RMSE(17)] = trainRegressionModel17(trainDataX(200:end,:));
[trainedModel18, RMSE(18)] = trainRegressionModel18(trainDataX(200:end,:));
[trainedModel19, RMSE(19)] = trainRegressionModel19(trainDataX(200:end,:));

Lin_Models = [trainedModel1, trainedModel2, trainedModel3, trainedModel4];
Tree_Models = [trainedModel5, trainedModel6, trainedModel7];
SVM_Models = [trainedModel8, trainedModel9, trainedModel10,...
    trainedModel11, trainedModel12, trainedModel13];
Ens_Models = [trainedModel14, trainedModel15];
GPR_Models = [trainedModel16, trainedModel17, trainedModel18, trainedModel19];

%% Plotting Model Accuracies:

total_models = [0 length(Lin_Models) length(Tree_Models) length(SVM_Models) length(Ens_Models) length(GPR_Models)];
CS = cumsum(total_models);

Title_names = ["Linear","Interactions Linear","Robust Linear","Stepwise Linear",...
    "Fine", "Medium", "Coarse",...
    "Linear", "Quadratic", "Cubic",...
    "Fine Gaussian","Medium Gaussian","Coarse Gaussian",...
    "Boosted Trees", "Bagged Trees",...
    "Squared Exp","Matern 5/2","Exponential","Rational Quadratic",]';

Title_group_names = ["Linear", "Tree", "SVM", "Ensemble", "Gaussian Process Regression"]';

cc = [0.7 0.7 0.7];

figure(1)
for i = 1:5
    gca = subplot(2,3,i);
    chart(i) = bar(RMSE(CS(i)+1:CS(i+1)),'FaceColor',cc);
    set(gca,'XTick', [1:total_models(i+1)]', 'XTickLabel', Title_names(CS(i)+1:CS(i+1)));
    xtickangle(30);
    xtips = chart(i).XData;
    ytips = RMSE(CS(i)+1:CS(i+1));
    labels = string(round(chart(i).YData,2));
    text(xtips,ytips,labels,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','color',circshift(cc-0.6,1));
    title(Title_group_names(i) + " models");
    ylim([0 1.2*max(RMSE)]);
    ylabel('RMSE');
end
mtit('Training model accuracies','fontsize',14,'color',[0 0 0],'xoff',0.37,'yoff',-0.7);
mtit('RMSE - Root mean square error','fontsize',9,'color',[0 0 0],'xoff',0.37,'yoff',-0.75);

figure(2);
gcb = subplot(1,1,1);
bar_chart_grp = bar(RMSE,0.5,'FaceColor',cc);
set(gcb,'XTick', [1:CS(end)]', 'XTickLabel', Full_Title_names);
xtickangle(30);
xtips = bar_chart_grp.XData;
ytips = 0.2 + RMSE;
labels = string(round(bar_chart_grp.YData,2));
text(xtips,ytips,labels,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom','color',circshift(cc-0.6,1))
ylim([0 1.2*max(RMSE)]);
title('Training model accuracies');
ylabel('RMSE');
