function output = rtClassifier(data, config)

% Params
nFolds = 1;
nPartitions = 5;

% PCA neural data, keep top 10 PCs
[data, ~, ~] = pca4Regression(data, 10, 0, 0);

% Average data over -100 to -10 and 10 to 100 ms
preBins = ismember(config.tPts, -100:10);
postBins = ismember(config.tPts, 10:100);
for tr = 1:length(data)
    data(tr).dataFull = data(tr).data;
    data(tr).data = [mean(data(tr).data(preBins,:));mean(data(tr).data(postBins,:))];
end

% Fit
labels = [0,1];
predictors = getPredictors(data, 'data', labels);
output = cvClassifier(predictors, nFolds, nPartitions);
[output.tPts] = deal(config.tPts);

% Project full time series
predictors = getPredictors(data, 'dataFull', labels);
output = projectClassifier(output, predictors, 'allnorm');

% Get crossing threshold
output = analyzeClassifier(output, [], 1:length(config.tPts));

% Save lift reaction times
trials = [data.trialNumber];
for m = 1:length(output)
    for tr = 1:length(output(m).projections)
        output(m).projections(tr).liftRT = data(trials == output(m).projections(tr).trialNumber).liftRT;
    end
end

end

function predictors = getPredictors(data, field, labels, preds, obs)

% Use all predictors
if nargin < 4
    preds = 1:size(data(1).(field),2);
end

% Use all observations
if nargin < 5
    obs = 1:size(data(1).(field),1);
end

data = data([data.locked]);
predictors = [];
for tr = 1:length(data)
    predictors(tr).data = data(tr).(field)(obs,preds);
    % The group this trial belongs to
    predictors(tr).label = data(tr).LR;
    % A label for every row in the data matrix, 0 before 1 after event
    % Passing in "labels" to separate pre and post event
    postEvent = labels == 1;
    preEvent = labels == 0;
    predictors(tr).labels = zeros(size(predictors(tr).data,1),1);
    predictors(tr).labels(postEvent) = 1;
    predictors(tr).labels(preEvent) = 0;
    predictors(tr).trialNumber = data(tr).trialNumber;
end

end

function output = analyzeClassifier(output, threshold, bins, tPts, nBeyond)

if nargin < 4
    nBeyond = 5;
end

% Compute threshold using method similar to Kaufman et al 2016 eLife
% Use the post-sigmoid projections, the log-odds of the outcome
% This is because imbalances in activity pre and post event can bias the
% pre projections to be strongly off of 0
if isempty(threshold)
    vals = cellfun(@(x) [x.projeval], {output.projections}, 'UniformOutput', false);
    vals = cellfun(@(x) x(:,2:2:end), vals, 'UniformOutput', false); % Have to get out only the 2nd projection
    vals = [vals{:}];
    med = median(vals,2);
    threshold = (max(med) + min(med)) / 2;
    thresholdleft = threshold;
    thresholdright = threshold; % Keeps variable names consistent even if not separating lefts and rights
    
    % Separately for lefts and rights
%     lefts = cell2mat(cellfun(@(x) [x.label], {output.projections}, 'UniformOutput', false)) == 1;
%     rights = cell2mat(cellfun(@(x) [x.label], {output.projections}, 'UniformOutput', false)) == 2;
%     medleft = median(vals(:,lefts),2);
%     thresholdleft = (max(medleft) + min(medleft)) / 2;
%     medright = median(vals(:,rights),2);
%     thresholdright = (max(medright) + min(medright)) / 2;

else
    thresholdleft = threshold;
    thresholdright = threshold;
end

% Computes bin where the projection first passes the threshold
% output must be passed through projectClassifier first

tPts = output(1).tPts;
timeBase = median(diff(tPts));
for m = 1:length(output)
    
    output(m).thresholdleft = thresholdleft;
    output(m).thresholdright = thresholdright;
    
    for tr = 1:length(output(m).projections)
        
        % Compute time bins beyond the threshold
        proj = output(m).projections(tr).projeval(bins,2);
        
        % Get separated LR thresholds, but compare them the same
        if output(m).projections(tr).label == 1
            threshold = thresholdleft;
        else
            threshold = thresholdright;
        end
        beyondThresh = proj >= threshold;
        
        % Find subsequences of 1s
        [subsequences, lengths] = findSubsequences(beyondThresh);
        
        % Save first bin of first subsequence past threshold
        if ~any(lengths >= nBeyond) % No subsequences of length found
            output(m).projections(tr).beyondbin = NaN;
            output(m).projections(tr).crosstime = NaN;
        else
            % Find first subsequence of length nBeyond
            ss = find(lengths >= nBeyond, 1, 'first');
            beyondbin = bins(subsequences{ss}(1));
            output(m).projections(tr).beyondbin = beyondbin;
            
            % Discard trials where the first identified bin is the first
            % bin
            if beyondbin == 1
                output(m).projections(tr).beyondbin = NaN;
                output(m).projections(tr).crosstime = NaN;
            % If the bin before the identified bin isn't below the
            % threshold we cannot interpolate, discard
            elseif output(m).projections(tr).projnorm(beyondbin - 1) > threshold
                output(m).projections(tr).beyondbin = NaN;
                output(m).projections(tr).crosstime = NaN;
            else
                % Interpolate to find time
                binFrac = (threshold - proj(beyondbin - 1)) / (proj(beyondbin) - proj(beyondbin - 1));
                crosstime = tPts(beyondbin - 1) + timeBase * binFrac;
                output(m).projections(tr).crosstime = crosstime;
            end
            
            % Debugging
            % fig;plot(tPts,proj);
            % line([tPts(1) tPts(end)], [0.5, 0.5], 'Color', [0,0,0]);
            % line(tPts([beyondbin beyondbin]), [-1, 1], 'Color', [1,0,0]);
            % line(tPts([beyondbin - 1 beyondbin - 1]), [-1, 1], 'Color', [0,1,0]);
            % line([crosstime crosstime], [-1 1], 'Color', [0,0,1]);
        end
    end
    
end
end
