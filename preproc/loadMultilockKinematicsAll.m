function kinematicsAll = loadMultilockKinematicsAll(datasets, dataPath)
% Loads multiple datasets, locks the kinematics and creates a single data
% struct combining across trials

kinematicsAll = [];
for dataset = datasets
    
    mouse = dataset{1}{1};
    session = dataset{1}{2};
    
    % Load and lock
    kinematics = loadMultilockKinematics(mouse, session, dataPath);
    % Concatenate
    kinematicsAll = cat(2, kinematicsAll, kinematics);
end

end

function [kinematics, R, M] = loadMultilockKinematics(mouse, session, dataPath)

% Load
[R, M, config] = loadData(mouse, session, 'R', 'DLC3', dataPath);

% Lock kinematics
config.preT = -100;
config.postT = 100;
config.tBase = 10;
config.smoothSD = 10;
eventNames = {'liftTimeDLC', 'zoneTime'};
goodtrs = ~isnan([R.(eventNames{1})]) & ~isnan([R.(eventNames{2})]) & [R.success] & ~isnan([R.grabTimeC]) & [R.liftRT] < 500 & [R.goodDLC] == 1 & [R.wrongZoneFirst] == 0 & [R.movementTime] < 500;
kinematics = multiEventLockKinematics(R(goodtrs), M, eventNames, config.preT, config.postT, config.tBase, 0);

% Add aperture details
kinematics = apertureFeatures(kinematics);

end