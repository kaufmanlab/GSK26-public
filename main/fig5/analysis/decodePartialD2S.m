function output = decodePartialD2S(kinematics, neurons, tBins, ROIs, kinematicField, neuralField)
% Fit instantaneous regression of joint angles with linear correlation of
% centroid distance to the spout removed

% Format kinematics
outcomes = kinematics([kinematics.locked]);
% Subselect to desired time period
for tr = 1:length(outcomes)
    outcomes(tr).data = cat(2, outcomes(tr).(kinematicField)(tBins, :));
    outcomes(tr).dist2Spout = outcomes(tr).dist2Spout(tBins,:,:);
end

% Regress off dist2Spout correlations
allJoints = cat(1,outcomes.data);
dist2Spout = cat(1, outcomes.dist2Spout);
dist2Spout = mean(dist2Spout(:,9:12,1),2);
meanDist2Spout = mean(dist2Spout); % scalar
% Fit betas
[~, betas, ~] = ridgeMML(allJoints, dist2Spout, 1);
% Subtract off prediction of each joint from dist2Spout
for tr = 1:length(outcomes)
    joints = outcomes(tr).data;
    dist = mean(outcomes(tr).dist2Spout(:,9:12,1),2);
    % Recon dist
    jointsHat = (dist - meanDist2Spout) * betas;
    jointsNoDist = joints - jointsHat;
    % Save
    outcomes(tr).data = jointsNoDist;
    outcomes(tr).ogData = joints;
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

% Alternative method
% Get betas and bias for each joint
% betas = zeros(1,size(allJoints,2));
% bias = zeros(1,size(allJoints,2));
% for j = 1:size(allJoints,2)
%     model = fitrlinear(dist2Spout, allJoints(:,j));
%     betas(j) = model.Beta;
%     bias(j) = model.Bias;
% end