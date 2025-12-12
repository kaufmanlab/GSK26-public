%% Figure 5 S2
YOURDATAPATH = '';
savePath = [YOURDATAPATH '/' 'models' '/'];

%% Load model outputs
load(sprintf('%sall_regression,M1,angles,radrates', savePath), 'outputsM1_rr')
load(sprintf('%sall_regression,S1,angles,radrates', savePath), 'outputsS1_rr')

%% Panel A and B:
% RADICaL angles proximal/distal partial decoding for all mice
field = 'outputPrxDst';
plotVEAll(outputsM1_rr, field, 0)
plotVEAll(outputsS1_rr, field, 1)

%% Panel C and D:
% RADICaL angles distance to spout partial decoding for all mice
field = 'outputD2S';
plotVEAll(outputsM1_rr, field, 0)
plotVEAll(outputsS1_rr, field, 1)

%% Panel E and F:
% Variance vs Variance Explained
plotVEvsVar(outputsM1_rr, 'output')
plotVEvsVar(outputsS1_rr, 'output')
