function output = loadTargetPartialClassifier(dataPath, mouse, session)
% Wrapper around targetPartialClassifier
% Load preprocessed data
% This data is already subsampled to the best 100 neurons and the desired
% time points
load(sprintf('%s%s_%s_cueLocked', dataPath, mouse, session), 'kinematics', 'neurons', 'M')

% Params
config = M.config;
config.type = 'logistic';

% Run svm
output = targetPartialClassifier(neurons, kinematics, config);

end