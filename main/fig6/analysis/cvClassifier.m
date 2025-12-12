function output = cvClassifier(data, nFolds, nPartitions, type, reg)

% The fraction test is 1/nPartitions * 100, for 5 partitions 20% of the 
% trials are held out in each model fit, making the cross validation an 
% 80/20 split
if nargin < 2
    % With nFolds and nPartitions at default, 10 models will be fit
    nFolds = 1;
end

if nargin < 3
    % Default is 80/20 train/test
    nPartitions = 5;
end

if nargin < 4
    type = 'logistic';
end

if nargin < 5
    reg = 'ridge'; 
end

% CV procedure
nModels = nFolds * nPartitions;

nTrials = length(data);
trainIdx = cell(1, nModels);
testIdx = cell(1, nModels);
for m = 1:nModels
    modVal = mod(m,nPartitions);
    if modVal == 1
        inds = randperm(nTrials);
    end
    trainIdx{m} = find(mod(inds,nPartitions) ~= (modVal));
    testIdx{m} = find(mod(inds,nPartitions) == (modVal));
end

% Data is a struct with fields .LR and .data
% .data is a matrix of time x predictors
% .label is 1 for left and 2 for right

% Allocate
output = struct();
for m = 1:nModels
    
    idxTrain = trainIdx{m};
    idxTest = testIdx{m};
    
    % Stratifying the train set, test does not need it
    idxTrain = idxTrain(stratify(cat(1, data(idxTrain).label)));
    
    % Save trial identities
    output(m).trialsTrain = cat(1, data(idxTrain).trialNumber);
    output(m).trialsTest = cat(1, data(idxTest).trialNumber);
    
    % Get labels and data for train and test
    trainData = cat(1, data(idxTrain).data);
    testData = cat(1, data(idxTest).data);
    trainLabels = cat(1, data(idxTrain).labels);
    testLabels = cat(1, data(idxTest).labels);
    
    % Fitting SVM to training data
    model = fitclinear(trainData, trainLabels, 'Learner', type, 'Regularization', reg);
    
    % Store data for each fold
    output(m).trainIdx = trainIdx{m};
    output(m).testIdx = testIdx{m};
    output(m).trainLabels = trainLabels;
    output(m).testLabels = testLabels;
    output(m).betas = model.Beta;
    output(m).bias = model.Bias;
    output(m).model = model;
    
    % Predict held-out data
    prediction = predict(model, testData);
    
    %     % Evaluate the fit
    %     diff = double(abs(prediction - testLabels)); % old and wrong, but
    %     keeping for reference, doesn't handle any labels other than 1 and 2,
    
    % Store performance for each fold
    accuracy = (sum(prediction == testLabels) / length(testLabels))*100;
    output(m).predLabels = prediction;
    output(m).performance = accuracy;
    
%     % Evaluate the fit 
%     diff = double(abs(prediction - testLabels));
%     
%     % Store performance for each fold
%     accuracy = (((length(testLabels) - sum(diff)) / length(testLabels))*100);
%     accuracy1v1 = (((length(testLabels) - sum(logical(diff))) / length(testLabels))*100);
%     output(m).predLabels = prediction;
%     output(m).performance = accuracy;
%     output(m).performance1v1 = accuracy1v1; % corrected for multiclass 1 v 1
end

end