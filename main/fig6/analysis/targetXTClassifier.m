function outputs = targetXTClassifier(data, config)

% Fit models on 100 ms periods nonoverlapping
config.tBins = config.preT:100:config.postT;
nFolds = 1;
nPartitions = 5;

outputs = [];
[outputs.tPtsTrain] = deal(NaN);
[outputs.models] = deal(NaN);
for train = 1:length(config.tBins)-1
    % Select a subset of time bins for each trained model
    fitBins = find(ismember(config.tPts, config.tBins(train):10:(config.tBins(train+1))-10));
    predictorsTrain = getPredictors(data, 'data', [], fitBins);
    output = cvClassifier(predictorsTrain, nFolds, nPartitions);
    
    % Evaluate all models on full time period, looping over individual bins
    for m = 1:length(output) % Over folds
        accuracy_all = zeros(1,length(config.tPts));
        for test = 1:length(config.tPts) % Over other time bins
            fitBins = find(ismember(config.tPts, config.tPts(test)));
            predictorsTest = getPredictors(data, 'data', [], fitBins);
            
            % Use only trials that were in the test set for this model
            testData = cat(1, predictorsTest(output(m).testIdx).data);
            testLabels = cat(1, predictorsTest(output(m).testIdx).labels);
            
            % Predict held-out data
            prediction = predict(output(m).model, testData);
            
            % Store performance for each fold
            accuracy = (sum(prediction == testLabels) / length(testLabels))*100;
            accuracy_all(test) = accuracy;
        end
        output(m).performance_all = accuracy_all;
    end
    outputs(train).models = output; 
    outputs(train).tPtsTrain = config.tBins(train):10:(config.tBins(train+1))-10;
end

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
