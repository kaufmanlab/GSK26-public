function [neurons, config, M] = lockNeural4Classifier(R, M, config)
% Lock neural activity for classifier models

if ~isfield(config, 'goodTrials')
    goodTrials = [R.success] & ~isnan([R.grabTimeC]) & [R.timeToContact] < 1000 & [R.liftRT] < 1000 & [R.goodDLC] == 1 & [R.liftRT] > 0 & [R.hasNeuralData];% & ~isnan([R.liftTimeDLC_locked]);
else
    goodTrials = config.goodTrials;
end

config.tPts = config.preT:config.tBase:config.postT;

% Get modulated neurons
if ~isfield(config, 'goodROIs')
    % Screen to the top 100 ZETA modulated cells
    pvals = min([M.modScores.waterTime; M.modScores.liftTimeDLC; M.modScores.grabTimeC]);
    [~, roiIdx] = sort(pvals);
    config.goodROIs = roiIdx(1:100);
end

% Lock data
neurons = eventLockDataSmooth(R(goodTrials), M, config.eventName, config.tPts, config.smoothSD, config.goodROIs);
goodTrials = find(goodTrials);
% Since eventLockData doesn't add this necessary information
for tr = 1:length(neurons)
    neurons(tr).LR = R(goodTrials(tr)).LR;
    neurons(tr).trialNumber = goodTrials(tr);
end

% Save eventTimes
if isfield(R, 'liftRT')
    for tr = 1:length(neurons)
        neurons(tr).liftRT = R(neurons(tr).trialNumber).liftRT;
        if isfield(R, 'liftRT_locked')
            neurons(tr).liftRT_locked = R(neurons(tr).trialNumber).liftTimeDLC_locked - R(neurons(tr).trialNumber).waterTime;
        else
            neurons(tr).liftRT_locked = NaN;
        end
        if isfield(R, 'movementTime')
            neurons(tr).zoneRT = R(neurons(tr).trialNumber).movementTime + neurons(tr).liftRT; % Sequence of two time intervals
        else
            neurons(tr).zoneRT = NaN;
        end
        neurons(tr).grabRT = R(neurons(tr).trialNumber).grabRT;
    end
end

end