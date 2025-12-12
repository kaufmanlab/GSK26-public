function output = decode(kinematics, neurons, tBins, ROIs, kinematicField, neuralField)
% Fit instantaneous regression

% Format kinematics
outcomes = kinematics([kinematics.locked]);
% Subselect to desired time period
for tr = 1:length(outcomes)
    outcomes(tr).data = cat(2, outcomes(tr).(kinematicField)(tBins, :));
    outcomes(tr).posXYZ = outcomes(tr).posXYZ(tBins,:,:); % Needed for reconstructions
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