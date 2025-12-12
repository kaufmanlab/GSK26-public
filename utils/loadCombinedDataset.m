function R = loadCombinedDataset(dataset, dataPath)
% Loads two datasets from the same mouse and combines them
mouse = dataset{1}{1};
session1 = dataset{1}{2};
session2 = dataset{1}{3};

% First
[R1, ~, ~] = loadData(mouse, session1, 'R', 'DLC3', dataPath);
% Second
[R2, ~, ~] = loadData(mouse, session2, 'R', 'DLC3', dataPath);

% Keep only necessary fields
R1 = keepFields(R1, {'success', 'grabTimeC', 'waterTime', 'liftTimeDLC', 'movementTime', 'liftRT', 'LR', 'goodDLC', 'wrongGrabFirst', 'zoneTime', 'nGrabs1000'});
R2 = keepFields(R2, {'success', 'grabTimeC', 'waterTime', 'liftTimeDLC', 'movementTime', 'liftRT', 'LR', 'goodDLC', 'wrongGrabFirst', 'zoneTime', 'nGrabs1000'});
R = cat(2, R1, R2);

end