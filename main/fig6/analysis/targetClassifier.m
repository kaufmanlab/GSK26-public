function output = targetClassifier(data, config)

% Params
nFolds = 1;
nPartitions = 5;

% Fit on only time period after cue
fitBins = find(ismember(config.tPts, 50:config.postT));
predictors = getPredictors(data, 'data', [], fitBins);

% Fit
output = cvClassifier(predictors, nFolds, nPartitions, config.type);

% Save details
[output.tPts] = deal(config.tPts);
[output.tPtsFit] = deal(config.tPts(fitBins));

% Project full time series
predictors = getPredictors(data, 'data');
output = projectClassifier(output, predictors, 'normLR');

% Threshold and distances
output = analyzeClassifier(output, [], fitBins);

% Get performance across bins
predictors = getPredictors(data, 'data', [], []);
output = projectBins(predictors, output);

end

function predictors = getPredictors(data, field, preds, obs)

% Use all predictors
if nargin < 3 || isempty(preds)
    preds = 1:size(data(1).(field),2);
end

% Use all observations
if nargin < 4 || isempty(obs)
    obs = 1:size(data(1).(field),1);
end

data = data([data.locked]);
predictors = [];
for tr = 1:length(data)
    predictors(tr).data = data(tr).(field)(obs,preds);
    % The group this trial belongs to
    predictors(tr).label = data(tr).LR;
    % A label for every row in the data matrix
    predictors(tr).labels = predictors(tr).label * ones(size(predictors(tr).data,1),1);
    predictors(tr).trialNumber = data(tr).trialNumber;
end
end

function output = analyzeClassifier(output, threshold, bins, nBeyond)

if nargin < 4
    nBeyond = 5;
end

% Compute threshold using method similar to Kaufman et al 2016 eLife
if isempty(threshold)
    vals = cellfun(@(x) [x.projnorm], {output.projections}, 'UniformOutput', false);
    vals = [vals{:}];
    % Separately for lefts and rights
    lefts = cell2mat(cellfun(@(x) [x.label], {output.projections}, 'UniformOutput', false)) == 1;
    rights = cell2mat(cellfun(@(x) [x.label], {output.projections}, 'UniformOutput', false)) == 2;
    medleft = median(vals(:,lefts),2);
    thresholdleft = (max(medleft) + min(medleft)) / 2;
    medright = median(vals(:,rights),2);
    thresholdright = (max(medright) + min(medright)) / 2;
else
    thresholdleft = -threshold;
    thresholdright = threshold;
end

% Computes bin where the projection first passes the threshold
% svmOutput must be passed through projectSVM first
tPts = output(1).tPts;
timeBase = median(diff(tPts));
for m = 1:length(output)
    
    % Save thresholds
    output(m).thresholdleft = thresholdleft;
    output(m).thresholdright = thresholdright;
    
    for tr = 1:length(output(m).projections)
        
        % Compute time bins beyond the threshold, subselect
        proj = output(m).projections(tr).projnorm(bins);
        
        if output(m).projections(tr).label == 1
            beyondThresh = proj <= thresholdleft;
        else
            beyondThresh = proj >= thresholdright;
        end
        
        % Find subsequences of 1s
        [subsequences, lengths] = findSubsequences(beyondThresh);
        
        % Save first bin of first subsequence past threshold
        if ~any(lengths >= nBeyond) % No subsequences of length found
            output(m).projections(tr).beyondbin = NaN;
            output(m).projections(tr).crosstime = NaN;
        else
            % Find first subsequence of length nBeyond
            ss = find(lengths >= nBeyond, 1, 'first');
            % index back into full time series
            beyondbin = bins(subsequences{ss}(1)); 
            output(m).projections(tr).beyondbin = beyondbin;
            
            % Error checking and interpolation to locked time base
            proj = output(m).projections(tr).projnorm;
            % If the first bin post cue is already above, discard trial
            if tPts(beyondbin) <= 0
                output(m).projections(tr).beyondbin = NaN;
                output(m).projections(tr).crosstime = NaN;
            else
                % Interpolate to find exact time, lefts and rights handled
                % differently
                if output(m).projections(tr).label == 1
                    % If the bin before the identified bin isn't below the
                    % threshold we cannot interpolate, discard
                    % I think this can't happen given the subsequence
                    % detection, but just in case
                    if proj(beyondbin - 1) < thresholdleft
                        binFrac = NaN;
                    else
                        binFrac = (thresholdleft - proj(beyondbin - 1)) / (proj(beyondbin) - proj(beyondbin - 1));
                    end
                else
                    if proj(beyondbin - 1) > thresholdright
                        binFrac = NaN;
                    else
                        binFrac = (thresholdright - proj(beyondbin - 1)) / (proj(beyondbin) - proj(beyondbin - 1));
                    end
                end
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
    
    % Compute similarity between projections onto the SVM dimension
    
    % Trials
    lefts = [output(m).projections.label] == 1;
    rights = [output(m).projections.label] == 2;
    
    % Matrix of projections
    projmat = cat(2,output(m).projections.projnorm);
    
    % Left and right separately
    leftdists = pdist(projmat(:,lefts)', 'cityblock');
    rightdists = pdist(projmat(:,rights)', 'cityblock');
    % Combine
    distsall = [leftdists, rightdists];
    
    % Save
    output(m).projdists = distsall;
    
end
end

function output = projectBins(predictors, output)
% Compute performance over time of the classifier

for m = 1:length(output)
   % Get test data, permute to put trials as observations
   testData = permute(cat(3, predictors(output(m).testIdx).data), [3,2,1]);
   predictions = zeros(size(testData,1),size(testData,3));
   for t = 1:size(testData,3)
       predictions(:,t) = predict(output(m).model, testData(:,:,t));
   end
   % Compute success, for each time bin via labels repped across bins
   % (columns)
   testLabelsAll = repmat([predictors(output(m).testIdx).label]', 1, size(testData,3));
   output(m).perfBins = (sum(predictions == testLabelsAll) ./ length(output(m).testIdx))*100;
end

end