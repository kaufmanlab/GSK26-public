function output = targetPartialClassifier(data, kinematics, config)

% Regress kinematics off of data
config.kinematicField = 'jointAngles';
data = partialOffKinematics(data, kinematics, config);

% Neural
% Fit
nFolds = 1;
nPartitions = 5;
fitBins = find(ismember(config.tPts, 50:config.postT));
predictors = getPredictors(data, 'data', [], fitBins);
output = cvClassifier(predictors, nFolds, nPartitions, config.type);

% Save details
[output.tPts] = deal(config.tPts);
[output.tPtsFit] = deal(config.tPts(fitBins));

% Get performance across bins
predictors = getPredictors(data, 'data', [], []);
output = projectBins(predictors, output);

end

function predictors = getPredictors(data, field, preds, obs)

% Use all predictors
if nargin < 3 || isempty(preds)
    preds = 1:size(data(1).(field),2);
end

% Use all observations
if nargin < 4 || isempty(obs)
    obs = 1:size(data(1).(field),1);
end

data = data([data.locked]);
predictors = [];
for tr = 1:length(data)
    predictors(tr).data = data(tr).(field)(obs,preds);
    % The group this trial belongs to
    predictors(tr).label = data(tr).LR;
    % A label for every row in the data matrix
    predictors(tr).labels = predictors(tr).label * ones(size(predictors(tr).data,1),1);
    predictors(tr).trialNumber = data(tr).trialNumber;
end

end

function output = projectBins(predictors, output)
% Compute performance over time of the classifier

for m = 1:length(output)
   % Get test data, permute to put trials as observations
   testData = permute(cat(3, predictors(output(m).testIdx).data), [3,2,1]);
   predictions = zeros(size(testData,1),size(testData,3));
   for t = 1:size(testData,3)
       predictions(:,t) = predict(output(m).model, testData(:,:,t));
   end
   % Compute success, for each time bin via labels repped across bins
   % (columns)
   testLabelsAll = repmat([predictors(output(m).testIdx).label]', 1, size(testData,3));
   output(m).perfBins = (sum(predictions == testLabelsAll) ./ length(output(m).testIdx))*100;
end

end

function data = partialOffKinematics(data, kinematics, config)

% Regress all kinematic information from neural, after R has been
% downsampled to the data struct

joints = cat(1,kinematics.(config.kinematicField));
neural = cat(1,data.data);
jointsMean = mean(joints, 1);

% Regress
[~, betas, ~] = ridgeMML(neural, joints, 1);
% Subtract out kinematic contribution to neural
for tr = 1:length(data)
    joints = kinematics(tr).(config.kinematicField);
    % Recon dist
    neuralHat = (joints - jointsMean) * betas;
    % Subtract off and save
    data(tr).ogdata = data(tr).data;
    data(tr).data = data(tr).data - neuralHat;
    % Debug
%     fig;plot(data(tr).data, 'r');plot(data(tr).ogdata, 'b');
%     pause;
%     close all;
end

end