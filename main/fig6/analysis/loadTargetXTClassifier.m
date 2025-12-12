function output = loadTargetXTClassifier(dataPath, mouse, session)
% Wrapper around targetXTClassifier
% Load preprocessed data
% This data is already subsampled to the best 100 neurons and the desired
% time points
load(sprintf('%s%s_%s_cueLockedXT', dataPath, mouse, session), 'neurons', 'M')

% Params
config = M.config;
config.type = 'logistic';

% Run svm
output = targetXTClassifier(neurons, config);

end