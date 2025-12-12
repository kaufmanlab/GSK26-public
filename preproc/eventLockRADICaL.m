function neurons = eventLockRADICaL(neurons, R, tPts, tPtsRADICaL, field)
% Only works for the original locking RADICaL was run on: liftTimeDLC

if nargin < 4
    field = 'radical_rates';
end

% tPtsRADICaL = -200:10:790; % From the paper
tBins2Use = ismember(tPtsRADICaL, tPts);

% Format neural
for tr = 1:length(neurons)
    trial = neurons(tr).trialNumber;
    
    neurons(tr).(field) = R(trial).(field)(tBins2Use,:);
    
end

end