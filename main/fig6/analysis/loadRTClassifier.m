function output = loadRTClassifier(dataPath, mouse, session)
% Wrapper around rtClassifier
% Load preprocessed data
% This data is already subsampled to the best 100 neurons and the desired
% time points
load(sprintf('%s%s_%s_liftLockedRT', dataPath, mouse, session), 'neurons', 'M')

% Params
config = M.config;
config.type = 'logistic';

% Run svm
output = rtClassifier(neurons, config);

end
