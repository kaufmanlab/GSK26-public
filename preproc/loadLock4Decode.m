function [kinematics, neurons, M, config] = loadLock4Decode(mouse, session, config)
% Loads and locks:
%   kinematics: eventLockKinematics struct
%   neurons: smoothed deconvolved events

% Lock data and screen cells
if nargin < 3
    config.preT = -100;
    config.postT = 400;
    config.tBase = 10;
    config.smoothSD = 35;
    config.eventName = 'liftTimeDLC';
end

% Load R struct with RADICaL for neural
[R, M, Rconfig] = loadData(mouse, session, 'R', 'DLC3', config.dataPath);

% Params
config.tPts = config.preT:config.tBase:config.postT;
goodTrials = [R.success] & ~isnan([R.grabTimeC]) & [R.liftRT] < 500 & [R.goodDLC] == 1 & [R.wrongZoneFirst] == 0 & [R.movementTime] < 500 & [R.timeToContact] < 1000 & [R.has_radical] == 1;
% Get smooth-deconv events
neurons = eventLockDataSmooth(R(goodTrials), M, config.eventName, config.tPts, config.smoothSD);
neurons = addTrialNumber(neurons, R(goodTrials));
% Add radical rates to struct with s-deconv
neurons = eventLockRADICaL(neurons, R, config.tPts, config.tPtsRADICaL, 'radical_rates');

% Kinematics
kinematics = eventLockKinematics(R(goodTrials), M, config.eventName, config.tPts, 'smoothMethod', 'Gaussian', 'gaussSD', 15);

% Save dataset info
config.datasetInfo = Rconfig;
end

function neurons = addTrialNumber(neurons,R)
% Must have matched trials

for tr = 1:length(neurons)
   neurons(tr).trialNumber = R(tr).trialNumber; 
end

end