function output = decodeResiduals(kinematics, neurons, tBins, ROIs, kinematicField, neuralField)

if nargin < 4
    kinematicField = 'jointAngles';
    neuralField = 'data';
end

if nargin < 5
    neuralField = 'data';
end

nFolds = 5;
nPartitions = 10;

% Prep for regression
outcomes = kinematics([kinematics.locked]);
% Subselect to desired time period
for tr = 1:length(outcomes)
    outcomes(tr).data = cat(2, outcomes(tr).(kinematicField)(tBins, :));
end

% Format neural
predictors = neurons([neurons.locked]);
for tr = 1:length(predictors)
    predictors(tr).data = predictors(tr).(neuralField)(tBins, ROIs);
    predictors(tr).group = outcomes(tr).LR;
    predictors(tr).trialNumber = outcomes(tr).trialNumber;
end

% Split into left and right trials, subtract off mean across trials and
% regress separately
outcomesL = outcomes([outcomes.LR] == 1);
predictorsL = predictors([predictors.group] == 1);
outcomesR = outcomes([outcomes.LR] == 2);
predictorsR = predictors([predictors.group] == 2);
% Get residuals
outcomesL = subtractAvg(outcomesL);
predictorsL = subtractAvg(predictorsL);
outcomesR = subtractAvg(outcomesR);
predictorsR = subtractAvg(predictorsR);

% PCA step on neural data
[predictorsL, ~] = pca4Regression(predictorsL, 0.9, 1, 0);
[predictorsR, ~] = pca4Regression(predictorsR, 0.9, 1, 0);

% cvRegress
outputL = cvRegress(predictorsL, outcomesL, nPartitions, nFolds, 'ridge');
outputR = cvRegress(predictorsR, outcomesR, nPartitions, nFolds, 'ridge');

% Save for outputs
output.outputL = outputL;
output.outputR = outputR;
output.outputL.outcomeIndices = cat(1,strrep([['lag1' kinematicField] '%s'], '%s', cellstr(num2str((1:size(outcomes(1).data,2))'))));
output.outputL.kinematicField = kinematicField;
output.outputL.neuralField = neuralField;
output.outputR.outcomeIndices = cat(1,strrep([['lag1' kinematicField] '%s'], '%s', cellstr(num2str((1:size(outcomes(1).data,2))'))));
output.outputR.kinematicField = kinematicField;
output.outputR.neuralField = neuralField;
end

function dataStruct = subtractAvg(dataStruct)
avgData = mean(cat(3, dataStruct.data),3);
for i = 1:length(dataStruct)
    dataStruct(i).data = dataStruct(i).data - avgData;
end
end