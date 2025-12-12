function [best, lossTest, lossTestSEMs, lossTrain] = crossvalPCAYu(data, labels, maxDim, method, nFolds, nVars)
% [best, lossTest, lossTrain] = crossvalPCAYu(data, labels [, maxDim] [, method] [, nFolds] [, nVars])
% 
% Cross-validation for PCA, using Byron Yu's method of double-holdout. We
% first hold out some observations and run PCA. In the held-out
% observations, we hold out a variable, use the other variables to estimate
% the low-D state via regression, and finally estimate the held-out
% variable in the held-out observations. We then rotate through all
% variables and observation labels.
%
% Two methods are available for determining the loss. The default is
% squared-error. Note that this is truly the squared error, so that we
% don't exclude the mean of the reconstruction from the denominator.
% Alternatively, we offer 1 - R^2, which ignores errors in the mean and
% will emphasize within-label variation instead of across-label variation.
% 
% INPUTS:
%  data   -- points x variables
%  labels -- points x 1. One label will be held out per fold. Thus, if you
%            want to hold out 20% of your data per fold, you should specify
%            5 labels.
%  maxDim -- optional. Maximum dimensionality to test. Default 20.
%  method -- optional. If 'var', takes the squared-error loss (default). If
%            'corr', takes 1 - R^2. Can use '' for default.
%  nFolds -- optional. If less than the number of unique labels, use this
%            many cross-validation folds. Default Inf (all labels).
%  nVars  -- optional. Number of variables to rotate through leaving out
%            per fold. (Only one variable will be left out at a time.)
%            Default Inf (all variables).
%
% OUTPUTS
%  best         -- the dimensionality with the lowest test loss (best
%                  guess for dimensionality)
%  lossTest     -- the loss for the test set at each dimensionality 
%                  1:maxDim (should be U-shaped)
%  lossTestSEMs -- SEM for the test loss at each dimensionality 1:maxDim.
%                  Computed across both folds and variables
%  lossTrain    -- the loss for the training set at each dimensionality
%                  1:maxDim (will be monotonically decreasing)
% 
% You probably wish to plot:
% figure; hold on; 
% plot(lossTest, 'b-o', 'LineWidth', 2); 
% for d = 1:length(lossTestSEMs)
%   plot([d d], lossTest(d) + [-1 1] * lossTestSEMs(d), 'r-', 'LineWidth', 1);
% end
% plot(best, lossTest(best), 'gx', 'LineWidth', 2);


%% Parameters

defaultMaxDim = 20;

% Minimum variance to consider this held-out variable on this fold for
% 'corr' method
varMin = 1e-8;


%% Basic error checking

if nargin < 2
  error('crossvalPCAYu:tooFewArgs', 'Must supply data and labels');
end


%% Optional arguments
% Be forgiving

if ~exist('maxDim', 'var')
  maxDim = min(defaultMaxDim, size(data, 2));
end

if ~exist('nFolds', 'var') || isnan(nFolds) || isempty(nFolds)
  nFolds = Inf;
end

if ~exist('nVars', 'var') || isnan(nVars) || isempty(nVars)
  nVars = Inf;
end

if ~exist('method', 'var') || isempty(method) || ~ischar(method)
  method = 1;
elseif strcmpi(method, 'corr')
  method = 2;
else
  method = 1;
end


%% Check labels validity

labels = labels(:);

if size(data, 1) ~= length(labels)
  error('crossvalPCAYu:badLabelLen', 'data should be points x variables, and labels should be points x 1');
end


%% Setup

uLabels = unique(labels);
nLabels = length(uLabels);

% Deal with too-high folds or variables requested

if ~isinf(nFolds) && nFolds > nLabels
  nFolds = Inf;
end

if ~isinf(nVars) && nVars > size(data, 2)
  nVars = Inf;
end

% Set up label lists and variable lists
if isinf(nFolds)
  folds = 1:nLabels;
else
  folds = randperm(nLabels, nFolds);
end

if isinf(nVars)
  vars = 1:size(data, 2);
else
  vars = randperm(size(data, 2), nVars);
end

% Pre-allocate
lossTest = NaN(length(folds), maxDim, length(vars));
lossTrain = NaN(length(folds), maxDim);


%% Main loop

for f = 1:length(folds)
  % Hold out label
  testLabel = uLabels(folds(f));
  dataTrain = data(labels ~= testLabel, :);
  means = mean(dataTrain);
  
  dataTest = data(labels == testLabel, :) - means;
  
  [coeff, ~, latent] = pca(dataTrain, 'NumComponents', maxDim);
  
  lossTrain(f, :) = 1 - cumsum(latent(1:maxDim)) / sum(latent);
  
  for d = 1:maxDim
    for v = 1:length(vars)
      % Estimate the low-D state XHat excluding the held-out variable,
      % using regression
      LHat = coeff(:, 1:d);
      LHat(vars(v), :) = [];
      
      dataTestPrime = dataTest;
      dataTestPrime(:, vars(v)) = [];
      
      XHat = (LHat' * LHat) \ LHat' * dataTestPrime';
      
      % Reconstruct the held-out variable
      YHat = XHat' * coeff(vars(v), 1:d)';
      
      % See how well we did
      if method == 1
        lossTest(f, d, v) = sum((dataTest(:, vars(v)) - YHat) .^ 2) / sum(dataTest(:, vars(v)) .^ 2);
      elseif method == 2
        theVar = var(dataTest(:, vars(v)));
        if theVar > varMin
          lossTest(f, d, v) = 1 - corr2(dataTest(:, vars(v)),YHat) .^ 2;
        end
      end
    end
  end
end


%% Summarize

lossTrain = mean(lossTrain, 1);

lossTestFVByD = reshape(permute(lossTest, [1 3 2]), [], maxDim);
lossTestSEMs = nanstd(lossTestFVByD) ./ sqrt(sum(~isnan(lossTestFVByD), 1));

lossTest = nanmean(nanmean(lossTest, 3), 1);

[~, best] = min(lossTest);
