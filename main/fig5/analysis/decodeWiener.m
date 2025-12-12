function output = decodeWiener(kinematics, neurons, tPts, ROIs, lags, kinematicField, neuralField)
% Fit a lagged Wiener filter model with specified lags
% lags must contain 0
% Note tPts argument instead of tBins, tPts is integer values of time
% points, ie -100:10:400

% For the first submission we fit RADICaL to the window -200:lift:800
% Thus we can only use up to -200 ms before lift for RADICaL-ized data

% For causal decoding and the default locking the first time bin of each 
% lagged neural data matrix is: -200, -180, -160, -140, -120, -100.
% This is not perfect given default smoothing and sub-frame alignment
% procedures, but it is a good proof of performance for a lagged model.

% The following cell comprehension gets the row indices for the original
% -200:10:600 locked data that become each lagged data matrix.
% We then column concatenate all lagged data matrices for each trial.

% Get lagged time bins
lagBins = cellfun(@(x) find(ismember(-200:10:600, x)), arrayfun(@(x) tPts + x, lags, 'UniformOutput', false), 'UniformOutput', false);

% Kinematics are not lagged
bins = lagBins{lags == 0};
outcomes = kinematics([kinematics.locked]);
% Subselect to desired time period
for tr = 1:length(outcomes)
    outcomes(tr).data = cat(2, outcomes(tr).(kinematicField)(bins,:));
end

% Format neural
predictors = neurons([neurons.locked]);
for tr = 1:length(predictors)
    % Subsample and concatenate
    data = [];
    for l = 1:length(lagBins)
        bins = lagBins{l};
        data = cat(2, data, predictors(tr).(neuralField)(bins, ROIs));
    end
    predictors(tr).data = data;
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