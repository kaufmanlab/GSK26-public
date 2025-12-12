function eventInfo = loadEventTimes(datasets, dataPath)
% Load all desired datasets and extract the single trial event times for
% relevant fields

% Loop over datasets
eventInfo = [];
count = 1;
for dataset = datasets
    % Load
    R = loadCombinedDataset(dataset, dataPath);
    
    % Choose trials
    R = R([R.success] & ~isnan([R.grabTimeC]) & [R.movementTime] < 1000 & [R.liftRT] < 500 & [R.goodDLC] == 1 & [R.wrongGrabFirst] == 0);
    lefts = [R.LR] == 1;
    rights = [R.LR] == 2;
    % Get values
    % Lifts
    liftTimes_R = [R(rights).liftTimeDLC] - [R(rights).waterTime];
    liftTimes_L = [R(lefts).liftTimeDLC] - [R(lefts).waterTime];
    
    % Contacts
    contactTimes_R = [R(rights).grabTimeC] - [R(rights).waterTime];
    contactTimes_L = [R(lefts).grabTimeC] - [R(lefts).waterTime];
    
    % Lift to zone
    lift2ZoneTime_R = [R(rights).zoneTime] - [R(rights).liftTimeDLC];
    lift2ZoneTime_L = [R(lefts).zoneTime] - [R(lefts).liftTimeDLC];
    
    % Lift to contact
    lift2ContactTime_R = [R(rights).grabTimeC] - [R(rights).liftTimeDLC];
    lift2ContactTime_L = [R(lefts).grabTimeC] - [R(lefts).liftTimeDLC];
    
    % Zone to contact
    graspTime_R = [R(rights).grabTimeC] - [R(rights).zoneTime];
    graspTime_L = [R(lefts).grabTimeC] - [R(lefts).zoneTime];
    
    % Number of contacts within 1000 ms
    nGrasps_R = [R(rights).nGrabs1000];
    nGrasps_L = [R(lefts).nGrabs1000];
    
    % Store data
    eventInfo(count).mouse = dataset{1}{1};
    eventInfo(count).liftRT_R = liftTimes_R;
    eventInfo(count).liftRT_L = liftTimes_L;
    eventInfo(count).contactRT_R = contactTimes_R;
    eventInfo(count).contactRT_L = contactTimes_L;
    eventInfo(count).lift2ZoneTimes_R = lift2ZoneTime_R;
    eventInfo(count).lift2ZoneTimes_L = lift2ZoneTime_L;
    eventInfo(count).lift2ContactTimes_R = lift2ContactTime_R;
    eventInfo(count).lift2ContactTimes_L = lift2ContactTime_L;
    eventInfo(count).graspTimes_R = graspTime_R;
    eventInfo(count).graspTimes_L = graspTime_L;
    eventInfo(count).nGrasps_R = nGrasps_R;
    eventInfo(count).nGrasps_L = nGrasps_L;
    
    count = count + 1;
end

end