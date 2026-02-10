function output = cvRegress(predictors, outcomes, nPartitions, nFolds, regType, fields, verbose)
% Performs cross-validated regression on single-trial data.
%
% This function fits a specified regression model (ridge or OLS) to predict
% outcome variables from predictor variables using k-fold cross-validation
% repeated over multiple random partitions of the data. It returns model
% performance metrics (variance explained), fitted regression coefficients,
% and the corresponding train/test trial indices.
%
% INPUTS:
%   predictors   - struct array of predictor data, one element per trial
%   outcomes     - struct array of outcome data, one element per trial
%   nPartitions  - (optional) number of random partitions (default = 10)
%   nFolds       - (optional) number of folds per partition (default = 5)
%   regType      - (optional) regression type: 'ridge' or 'ols' (default = 'ridge')
%   fields       - (optional) cell array {predictorField, outcomeField} specifying
%                  which fields to use from each struct (default = {'data','data'})
%   verbose      - (optional) flag to print progress (default = 1)
%
% OUTPUT:
%   output - struct containing:
%       .regType       - regression type used
%       .nFolds        - number of folds
%       .nPartitions   - number of partitions
%       .nModels       - total number of fitted models (nFolds * nPartitions)
%       .VEs           - variance explained on test sets
%       .trainVEs      - variance explained on training sets
%       .medianVEs     - median VE across models
%       .betas         - fitted regression coefficients
%       .trainInds     - trial indices used for training
%       .testInds      - trial indices used for testing
%       .trialsTrain   - actual trial numbers used for training
%       .trialsTest    - actual trial numbers used for testing
%       .predictors    - input predictor struct
%       .outcomes      - input outcome struct
%       .fields        - field names used for regression
%
% Example:
%   output = cvRegress(predictors, outcomes, 10, 5, 'ridge');
%
% Notes:
% - Performs an nPartitions × nFolds cross-validation, e.g. 10×5 = 50 total fits.
% - Each fold holds out 1/nPartitions of trials for testing (e.g., 20% for 5 partitions).
% - Default is 90/10 train/test

%% Arguments

if nargin < 3
    nFolds = 5;
end

if nargin < 4
    nPartitions = 10;
end

if nargin < 5
    regType = 'ridge';
end

if nargin < 6
    predField = 'data';
    outField = 'data';
    fields = {outField, predField};
else
    predField = fields{1};
    outField = fields{2};
end

if nargin < 7
    verbose = 1;
end

% Make sure predictors and outcomes match in number of trials
assert(length(predictors) == length(outcomes))

% Make sure predictors and outcomes match in identities of trials
assert(all([predictors.trialNumber] == [outcomes.trialNumber]))

% Get data size info
nTrials = length(predictors);
firstTrialwithData = find(cellfun(@(x) ~isempty(x), {outcomes.(outField)}), 1, 'first');
nPredictors = size(predictors(firstTrialwithData).(predField),2);
nOutcomes = size(outcomes(firstTrialwithData).(outField),2);
trialNumbers = [outcomes.trialNumber];

%% Allocate for betas and trials used in each fold
% Determine number of times the model is fit
% nPartitions is the number of times we do the nFold cross validation

nModels = nFolds * nPartitions;
VEs = NaN(nModels, nOutcomes);
trainVEs = NaN(nModels, nOutcomes);
betas = cell(1, nModels);
trainInds = cell(1, nModels);
testInds = cell(1, nModels);
trialsTrain = cell(1, nModels);
trialsTest = cell(1, nModels);

%% Communicate
if verbose
    fprintf('cvRegress: Regressing %i outcomes on %i predictors \n', nOutcomes, nPredictors);
    fprintf('cvRegress: Cross validating VE over %i trials with %i models, via %i partitions and %i folds \n', nTrials, nModels, nPartitions, nFolds);
end

% Time it
tAll = tic;

%% Set up fold partitions across trials
% Use the mod of the model idx as the partition mod value, then loop over
% repermuting trial indices only every nPartition-th model

for m = 1:nModels
    modVal = mod(m,nPartitions);
    if modVal == 1
        inds = randperm(nTrials);
    end
    trainInds{m} = find(mod(inds,nPartitions) ~= (modVal));
    testInds{m} = find(mod(inds,nPartitions) == (modVal));
end

%% Cross validate all models
for m = 1:nModels
    % Get this fit's trial indices
    trTrain = trainInds{m};
    trTest = testInds{m};
    
    % Actual trial identities to use later
    trialsTrain{m} = trialNumbers(trTrain);
    trialsTest{m} = trialNumbers(trTest);
    
    outcomesMtrain = cat(1, outcomes(trTrain).(outField)); % Concatenate all fields vertically
    predictorsMtrain = cat(1, predictors(trTrain).(predField));
    
    outcomesMtest = cat(1, outcomes(trTest).(outField)); % Concatenate all fields vertically
    predictorsMtest = cat(1, predictors(trTest).(predField));
    
    switch regType
        
        case 'ridge'
            
            [~, betasTrain, ~] = ridgeMML(outcomesMtrain, predictorsMtrain, 0);
            betas{m} = betasTrain;
            
            % Reconstruct
            outcomesMtestHat = predictorsMtest * betasTrain(2:end, :) + betasTrain(1, :);
            outcomesMtrainHat = predictorsMtrain * betasTrain(2:end, :) + betasTrain(1, :);
            
            % Below was used in first submission, corrected to above in
            % resubmission
            %outcomesMtestHat = (predictorsMtest - mean(predictorsMtest, 1)) * betasTrain;
            %outcomesMtrainHat = (predictorsMtrain - mean(predictorsMtrain, 1)) * betasTrain;
            
            VEs(m, :) = 1 - var(outcomesMtest - outcomesMtestHat, [], 1)./var(outcomesMtest, [], 1);
            trainVEs(m, :) = 1 - var(outcomesMtrain - outcomesMtrainHat, [], 1)./var(outcomesMtrain, [], 1);
            
        case 'ols'
            
            betasTrain = pinv(predictorsMtrain)*outcomesMtrain;
            betas{m} = betasTrain;
            
            outcomesMtestHat = predictorsMtest * betasTrain;
            outcomesMtrainHat = predictorsMtrain * betasTrain;
            
            VEs(m, :) = 1 - var(outcomesMtest - outcomesMtestHat, [], 1)./var(outcomesMtest, [], 1);
            trainVEs(m, :) = 1 - var(outcomesMtrain - outcomesMtrainHat, [], 1)./var(outcomesMtrain, [], 1);

            
        otherwise
            error('%s as a regression method has not been implemented', regType);
    end
    
    if verbose
        if mod(m, nPartitions) == 0
            fprintf('cvregress: Finished %i model fits in 0%.1fs \n', m, toc(tAll));
        end
    end
    
end

% Package up outputs
output.regType = regType;
output.nFolds = nFolds;
output.nPartitions = nPartitions;
output.nModels = nModels;
output.trainVEs = trainVEs;
output.VEs = VEs;
output.medianVEs = median(VEs, 2);
output.trialsTrain = trialsTrain;
output.trialsTest = trialsTest;
output.trainInds = trainInds;
output.testInds = testInds;
output.predictors = predictors;
output.outcomes = outcomes;
output.betas = betas;
output.fields = fields;

if verbose
    fprintf('cvregress: Finished in total 0%.1fs \n', toc(tAll));
    fprintf('cvregress: Across %i models and %i outcomes, Mean VE %f and Median VE %f\n', nModels, nOutcomes, mean(mean(VEs)), median(median(VEs)));
end

end