%% Figure 6 analysis
% Runs condition, condition-kinematics-partial-ed, lift-time, and 
% time-generalized classifiers using smoothed-deconvolved events

%% Paths
YOURDATAPATH = '/Users/hank/Documents/MATLAB/kaufmanlab/data/P1/';
dataPath = [YOURDATAPATH '/' 'locked' '/'];
savePath = [YOURDATAPATH '/' 'models' '/'];

%% Dataset info
mouseInfo = {{'cfa17', '200825', '200827'}, ...
    {'cfa19', '200820', '200826'}, ...
    {'cfa20', '201114', '201118'}, ...
    {'cfa22', '220605', '220611'}, ...
    {'cfa24', '220727', '220724'}};

%% Decode targets from all datasets, smoothed deconvolved
outputsLR = loadClassifierAll(dataPath, mouseInfo, 'target');

%% Save
save(sprintf('%sall_classifier,target', savePath), 'outputsLR', '-v7.3')

%% Decode reaction time from all datasets, smoothed deconvolved
outputsRT = loadClassifierAll(dataPath, mouseInfo, 'RT');

%% Save
save(sprintf('%sall_classifier,RT', savePath), 'outputsRT', '-v7.3')

%% Decode targets from all datasets, with time generalization, smoothed deconvolved
outputsXT = loadClassifierAll(dataPath, mouseInfo, 'targetXT');

%% Save
save(sprintf('%sall_classifier,XT', savePath), 'outputsXT', '-v7.3')

%% Decode targets from all datasets, smoothed deconvolved, kinematics regressed off
outputsPartialLR = loadClassifierAll(dataPath, mouseInfo, 'targetPartial');

%% Save
save(sprintf('%sall_classifier,targetPartial', savePath), 'outputsPartialLR', '-v7.3')