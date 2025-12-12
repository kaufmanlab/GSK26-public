function output = loadTargetClassifier(dataPath, mouse, session)
% Wrapper around targetClassifier
% Load preprocessed data
% This data is already subsampled to the best 100 neurons and the desired
% time points
load(sprintf('%s%s_%s_cueLocked', dataPath, mouse, session), 'neurons', 'M')

% Params
config = M.config;
config.type = 'logistic';

% Run svm
output = targetClassifier(neurons, config);

end