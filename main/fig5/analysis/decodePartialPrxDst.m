function output = decodePartialPrxDst(kinematics, neurons, tBins, ROIs, kinematicField, neuralField)
% Fit instantaneous regression of joint angles with proximal and distal
% variances partial'ed

prox = 1:7;
dist = 8:24;

% Format kinematics
outcomes = kinematics([kinematics.locked]);
% Subselect to desired time period
for tr = 1:length(outcomes)
    outcomes(tr).data = cat(2, outcomes(tr).(kinematicField)(tBins, :));
end

% Regress off distal and proximal joints from one another
joints = cat(1,outcomes.data);
prxAngles = joints(:,prox);
prxMean = mean(prxAngles,1);
dstAngles = joints(:,dist);
dstMean = mean(dstAngles,1);
[~, prox2DistBetas, ~] = ridgeMML(dstAngles, prxAngles, 1);
[~, dst2ProxBetas, ~] = ridgeMML(prxAngles, dstAngles, 1);
% Subtract out proximal contribution to distal
for tr = 1:length(outcomes)
    prx = outcomes(tr).data(:,prox);
    dst = outcomes(tr).data(:,dist);
    % Recon dist
    dstHat = (prx - prxMean) * prox2DistBetas;
    dstNoPrx = dst - dstHat;
    % Recon prx
    prxHat = (dst - dstMean) * dst2ProxBetas;
    prxNoDst = prx - prxHat;
    % Concatenate
    outcomes(tr).ogData = outcomes(tr).data;
    outcomes(tr).data = cat(2, prxNoDst, dstNoPrx);
end

% Format neural
predictors = neurons([neurons.locked]);
for tr = 1:length(predictors)
    predictors(tr).data = predictors(tr).(neuralField)(tBins, ROIs);
    predictors(tr).group = outcomes(tr).LR;
    predictors(tr).trialNumber = outcomes(tr).trialNumber;
end

% PCA step on neural data
[predictors, PCs] = pca4Regression(predictors, 0.9, 1, 0);

% cvRegress
nFolds = 5;
nPartitions = 10;
output = cvRegress(predictors, outcomes, nPartitions, nFolds, 'ridge');
output.outcomeIndices = cat(1,strrep([['lag1' kinematicField] '%s'], '%s', cellstr(num2str((1:size(outcomes(1).data,2))'))));
output.PCs = PCs;
output.kinematicField = kinematicField;
output.neuralField = neuralField;
end