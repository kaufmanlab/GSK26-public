%% Figure 3 main
YOURDATAPATH = '';

%% Panels A,B,D use mouse 1
mouse = 'cfa17';
session = '200825';
[R, M, config] = loadData(mouse, session, 'R', 'DLC3', YOURDATAPATH);

% Lock data for joint angle time series
config.preT = -100;
config.postT = 400;
config.tBase = 10;
config.tPts = config.preT:config.tBase:config.postT;
eventName = 'liftTimeDLC';
goodTrials = find([R.success] & ~isnan([R.grabTimeC]) & [R.movementTime] < 1000 & [R.liftRT] < 500 & [R.goodDLC] == 1);
kinematics = eventLockKinematics(R(goodTrials), M, eventName, config.tPts, 'smoothMethod', 'Gaussian', 'gaussSD', 15);

%% Panel A:
% Skeletal representation of joint angles

% Params
trial = 3;
trial = find([kinematics.trialNumber] == trial);
tPt = 20;
prox_cmap = repmat([215, 15, 175]/255, 3,1);
dist_cmap = repmat([255, 160, 25]/255, 12,1);
view = [-42, 10.5];
M.plotParams.markers2Plot = 1:15;
M.plotParams.skeleton2Plot = [M.skeleton(1:17,:)];
M.plotParams.markerSizes = [6, 6, 6, 6, 12, 12, 12, 12, 14, 14, 14, 14, 20, 26, 32];
M.plotParams.linkColors = repmat([0.85, 0.85, 0.85], length(M.plotParams.skeleton2Plot),1);
M.plotParams.markerColors = repmat([0.35,0.35,0.35], length(M.plotParams.markers2Plot), 1);

% Plot
plotSkeletonEulerAngles(kinematics(trial), tPt, M.plotParams, view)

%% Panel B:
% Joint angle time series
joints = [1,4,5,8,21];
plotJointAnglesVertical(kinematics, joints)

%% Get data for panels C,E:
mouseInfoAll = {{'cfa17', '200825'}, ...
    {'cfa17', '200827'}, ...
    {'cfa19', '200820'}, ...
    {'cfa19', '200826'}, ...
    {'cfa20', '201114'}, ...
    {'cfa20', '201118'}, ...
    {'cfa22', '220605'}, ...
    {'cfa22', '220611'}, ...
    {'cfa24', '220724'}, ...
    {'cfa24', '220727'}};

% Get kinematics for all datasets, this will take a few minutes
kinematics = loadLockKinematicsAll(mouseInfoAll, YOURDATAPATH);

%% Panel C:
% Joint angle correlation matrices
plotJointAngleCorr(kinematics, 'jointAngles')

%% Panel D:
% Joint angle cvPCA dimensionality for mouse 1

% Compute dimensionalities for all animals, this will take a few seconds
rng(240924);
[lossTests, lossSEMs] = jointKinematicsCVPCA(kinematics);

% Plot
plotJointKinematicsCVPCALoss(lossTests, lossSEMs, 1, 16)

%% Panel E:
% Pair plot of dimensionality of joint angles and velocities
plotJointKinematicsCVPCA(lossTests)