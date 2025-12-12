%% Figure 6 main
YOURDATAPATH = '';
savePath = [YOURDATAPATH '/' 'models' '/'];

%% Load model outputs
load(sprintf('%sall_classifier,target', savePath), 'outputsLR')
load(sprintf('%sall_classifier,RT', savePath), 'outputsRT')
load(sprintf('%sall_classifier,XT', savePath), 'outputsXT')

%% PANEL A
% Plot classifier projections for mouse 1
plotTargetClassifierProj(outputsLR(1).M1, 'projnorm')
plotTargetClassifierProj(outputsLR(1).S1, 'projnorm')

%% PANEL B
% Classifier threshold cross time violin plots for all mice
plotTargetClassifierTimingAll(outputsLR)

%% PANEL C
% Correlation between predicted and real reaction times for all mice
plotRTClassifierCorrelationAll(outputsRT, 'liftRT')

%% PANEL D
% Plot heat map of cross-time target decoder generalization
plotTargetXTPerformanceAll(outputsXT);
