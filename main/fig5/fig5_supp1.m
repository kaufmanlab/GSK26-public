%% Figure 5 S1
YOURDATAPATH = '/Users/hank/Documents/MATLAB/kaufmanlab/data/P1/';
savePath = [YOURDATAPATH '/' 'models' '/'];

%% Load model outputs
% sdeconv
load(sprintf('%sall_regression,M1,angles,sdeconv', savePath), 'outputsM1_sd')
load(sprintf('%sall_regression,S1,angles,sdeconv', savePath), 'outputsS1_sd')
% radrates velocities
load(sprintf('%sall_regression,M1,velocities,radrates', savePath), 'outputsM1_rv')
load(sprintf('%sall_regression,S1,velocities,radrates', savePath), 'outputsS1_rv')

%% Panel A and B:
% sdeconv decoding for all mice
field = 'output';
plotVEAll(outputsM1_sd, field, 0)
plotVEAll(outputsS1_sd, field, 1)

%% Panel C and D:
% RADICaL velocity decoding for all mice
field = 'output';
plotVEAll(outputsM1_rv, field, 0)
plotVEAll(outputsS1_rv, field, 1)