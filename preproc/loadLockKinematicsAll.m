function kinematicsAll = loadLockKinematicsAll(datasets, dataPath)
% Loads multiple datasets, locks the kinematics and creates a single data
% struct combining across trials

kinematicsAll = [];
for dataset = datasets
    
    mouse = dataset{1}{1};
    session = dataset{1}{2};
    
    % Load and lock
    kinematics = loadLockKinematics(mouse, session, dataPath);
    % Concatenate
    kinematicsAll = cat(2, kinematicsAll, kinematics);
end

end

function [kinematics, R, M] = loadLockKinematics(mouse, session, dataPath)

% Load
[R, M, config] = loadData(mouse, session, 'R', 'DLC3', dataPath);

% Lock kinematics
config.preT = -100;
config.postT = 400;
config.tBase = 10;
config.tPts = config.preT:config.tBase:config.postT;
eventName = 'liftTimeDLC';
goodTrials = find([R.success] & ~isnan([R.grabTimeC]) & [R.movementTime] < 1000 & [R.liftRT] < 500 & [R.goodDLC] == 1);
kinematics = eventLockKinematics(R(goodTrials), M, eventName, config.tPts, 'smoothMethod', 'Gaussian', 'gaussSD', 15);

end