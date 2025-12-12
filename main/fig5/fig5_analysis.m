%% Figure 5 analysis
% Runs regression analysis for all model configurations, for RADICaL rates
% and for smoothed-deconvolved events

% Model configurations:
% Instantaneous, proximal-distal partial, spout-distance partial, causal
% Wiener filter, acausal Wiener filter

%% Preprocess data
% Before running this script, run the script loadLockSave.mat to create the
% multiple different locked datasets required for this script

%% Paths
YOURDATAPATH = '';
dataPath = [YOURDATAPATH '/' 'locked' '/'];
savePath = [YOURDATAPATH '/' 'models' '/'];

%% Dataset info
mouseInfoM1 = {{'cfa17', '200825'}, {'cfa19', '200820'}, {'cfa20', '201114'}, {'cfa22', '220605'}, {'cfa24', '220727'}};
mouseInfoS1 = {{'cfa17', '200827'}, {'cfa19', '200826'}, {'cfa20', '201118'}, {'cfa22', '220611'}, {'cfa24', '220724'}};

%% Decode joint angles from all datasets, radical_rates

% Set rng for reproducibility
rng(240926);
outputsM1_rr = loadDecodeAll(dataPath, mouseInfoM1, 'jointAngles', 'radical_rates');
outputsS1_rr = loadDecodeAll(dataPath, mouseInfoS1, 'jointAngles', 'radical_rates');

%% Save
save(sprintf('%sM1,regression,angles,radrates', savePath), 'outputsM1_rr', '-v7.3')
save(sprintf('%sS1,regression,angles,radrates', savePath), 'outputsS1_rr', '-v7.3')

%% Decode joint angles from all datasets, smoothed deconvolved

% Set rng for reproducibility
rng(240926);
fitModels = [1,0,0,0,0,0]; % don't run controls, we aren't plotting them for sdeconv
outputsM1_sd = loadDecodeAll(dataPath, mouseInfoM1, 'jointAngles', 'data', fitModels);
outputsS1_sd = loadDecodeAll(dataPath, mouseInfoS1, 'jointAngles', 'data', fitModels); % 'data' corresponds to smoothed deconvolved neural activity

%% Save
save(sprintf('%sM1,regression,angles,sdeconv', savePath), 'outputsM1_sd', '-v7.3')
save(sprintf('%sS1,regression,angles,sdeconv', savePath), 'outputsS1_sd', '-v7.3')

%% Decode joint velocities from all datasets, radical_rates

% Set rng for reproducibility
rng(240926);
fitModels = [1,0,0,0,0,0]; % don't run controls, we aren't plotting them for joint velocities
outputsM1_rv = loadDecodeAll(dataPath, mouseInfoM1, 'jointVelocities', 'radical_rates', fitModels);
outputsS1_rv = loadDecodeAll(dataPath, mouseInfoS1, 'jointVelocities', 'radical_rates', fitModels);

%% Save
save(sprintf('%sM1,regression,velocities,radrates', savePath), 'outputsM1_rv', '-v7.3')
save(sprintf('%sS1,regression,velocities,radrates', savePath), 'outputsS1_rv', '-v7.3')