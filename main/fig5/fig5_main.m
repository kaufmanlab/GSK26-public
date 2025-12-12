%% Figure 5 main
YOURDATAPATH = '';
savePath = [YOURDATAPATH '/' 'models' '/'];

%% Load model outputs
load(sprintf('%sall_regression,M1,angles,radrates', savePath), 'outputsM1_rr')
load(sprintf('%sall_regression,S1,angles,radrates', savePath), 'outputsS1_rr')

%% Panel A and B:
% RADICaL decoding for mouse 1
plotVE(outputsM1_rr(1).output, 0)
plotVE(outputsS1_rr(1).output, 1)

%% Panel C/D:
% Joint angle time series with reconstructions
joints = [1,4,5,8,21];
ylims = jointsReconPlot(outputsM1_rr(1).output, joints, 'jointAngles'); % .jointAngles was renamed to '.data'
jointsReconPlot(outputsS1_rr(1).output, joints, 'jointAngles', ylims);

%% Panel E/F:

% Find trials to reconstruct
trialIdxL = find([outputsM1_rr(1).output.outcomes.LR] == 1);
medVEs = median(cat(1,outputsM1_rr(1).output.outcomes(trialIdxL).jointAnglesReconVE),2);
medVE = median(medVEs);
[~, medTrialL] = min(abs(medVEs - medVE));
medTrialL_M1 = trialIdxL(medTrialL);

trialIdxR = find([outputsM1_rr(1).output.outcomes.LR] == 2);
medVEs = median(cat(1,outputsM1_rr(1).output.outcomes(trialIdxR).jointAnglesReconVE),2);
medVE = median(medVEs);
[~, medTrialR] = min(abs(medVEs - medVE));
medTrialR_M1 = trialIdxR(medTrialR);

trialIdxL = find([outputsS1_rr(1).output.outcomes.LR] == 1);
medVEs = median(cat(1,outputsS1_rr(1).output.outcomes(trialIdxL).jointAnglesReconVE),2);
medVE = median(medVEs);
[~, medTrialL] = min(abs(medVEs - medVE));
medTrialL_S1 = trialIdxL(medTrialL);

trialIdxR = find([outputsS1_rr(1).output.outcomes.LR] == 2);
medVEs = median(cat(1,outputsS1_rr(1).output.outcomes(trialIdxR).jointAnglesReconVE),2);
medVE = median(medVEs);
[~, medTrialR] = min(abs(medVEs - medVE));
medTrialR_S1 = trialIdxR(medTrialR);

% Params
M.plotParams.markerSizes = [10, 10, 10, 10, 14, 14, 14, 14, 18, 18, 18, 18, 24, 30, 38]/5;
M.skeleton = [1, 5;2, 6;3, 7;4, 8;9, 5;10, 6;11, 7;12, 8;10, 9;11, 10;12, 11;13, 9;13, 10;13, 11;13, 12;13, 14;14, 15;17, 16;19, 18;20, 22;21, 22;21, 20;23, 25;24, 25;24, 23];

% Plot skeletons
% M1 L
trialIdx = medTrialL_M1;
frames = 11:3:29;
offsets = repmat([0,0,0],length(frames),1);
offsets(:,1) = linspace(0, 100, length(frames))';
reconPosePlot(outputsM1_rr(1).output, M, trialIdx, frames, offsets)

% M1 R
trialIdx = medTrialR_M1;
frames = 11:3:29;
offsets = repmat([0,0,0],length(frames),1);
offsets(:,1) = linspace(0, 100, length(frames))';
reconPosePlot(outputsM1_rr(1).output, M, trialIdx, frames, offsets)
set(gca, 'View', [-23 5])

% S1 L
trialIdx = medTrialL_S1;
frames = 11:3:29;
offsets = repmat([0,0,0],length(frames),1);
offsets(:,1) = linspace(0, 100, length(frames))';
reconPosePlot(outputsS1_rr(1).output, M, trialIdx, frames, offsets)

% S1 R
trialIdx = medTrialR_S1;
frames = 11:3:29;
offsets = repmat([0,0,0],length(frames),1);
offsets(:,1) = linspace(0, 100, length(frames))';
reconPosePlot(outputsS1_rr(1).output, M, trialIdx, frames, offsets)
set(gca, 'View', [-23 5])

%% PANEL G/H:
% All RADICaL decoding
field = 'output';
plotVEAll(outputsM1_rr, field, 0)
plotVEAll(outputsS1_rr, field, 1)