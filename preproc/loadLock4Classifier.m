function [neurons, M, config, kinematics] = loadLock4Classifier(mouse, session, config)
% Loads and locks:
%   kinematics: eventLockKinematics struct (ignored if not needed)
%   neurons: smoothed deconvolved events

% Load R struct with RADICaL for neural
[R, M, Rconfig] = loadData(mouse, session, 'R', 'DLC3', config.dataPath);

% Get neural data
[neurons, config, M] = lockNeural4Classifier(R, M, config);

% Save dataset info
config.datasetInfo = Rconfig;

% Get kinematics if desired
if nargout > 3
    kinematics = eventLockKinematics(R([neurons.trialNumber]), M, config.eventName, config.tPts, 'smoothMethod', 'Gaussian', 'gaussSD', 15);
end