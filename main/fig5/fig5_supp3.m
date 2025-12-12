%% Figure 5 S3
YOURDATAPATH = '';
savePath = [YOURDATAPATH '/' 'models' '/'];

%% Load model outputs
load(sprintf('%sall_regression,M1,angles,radrates', savePath), 'outputsM1_rr')
load(sprintf('%sall_regression,S1,angles,radrates', savePath), 'outputsS1_rr')

%% A-D Residual decoding
% A-B
field = 'outputResL';
plotVEAll(outputsM1_rr, field, 0)
field = 'outputResL';
plotVEAll(outputsS1_rr, field, 1)
% C-D
field = 'outputResR';
plotVEAll(outputsM1_rr, field, 0)
field = 'outputResR';
plotVEAll(outputsS1_rr, field, 1)

%% E-F causal Wiener filter decoding
field = 'outputWc';
plotVEAll(outputsM1_rr, field, 0)
field = 'outputWc';
plotVEAll(outputsS1_rr, field, 1)

%% G-H acausal Wiener filter decoding
field = 'outputWa';
plotVEAll(outputsM1_rr, field, 0)
field = 'outputWa';
plotVEAll(outputsS1_rr, field, 1)