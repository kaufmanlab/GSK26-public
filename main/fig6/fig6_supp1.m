%% Figure 6 S1
YOURDATAPATH = '';
savePath = [YOURDATAPATH '/' 'models' '/'];

%% Load model outputs
load(sprintf('%sall_classifier,target', savePath), 'outputsLR')
load(sprintf('%sall_classifier,targetPartial', savePath), 'outputsPartialLR')

%% PANEL A
% Classifier performance over time for target decoder
plotTargetClassifierPerformanceAll(outputsLR)

%% PANEL B
% Classifier performance over time for target decoder, kinematics
% partial-ed off
plotTargetClassifierPerformanceAll(outputsPartialLR)