function output = projectClassifier(output, data, method)

% Project new data into fit SVM dimensions, replicating cross validation
% structure from the fitting process
for m = 1:length(output)
    
    % Get trials to project
    trialsTest = output(m).trialsTest';
    % Allocate
    projections = struct();
    for tr = 1:length(trialsTest)
        % Index into struct
        trial = find([data.trialNumber] == trialsTest(tr));
        
        % Manual projection of data onto classifier dimension, no
        % evaluation of link function
        proj = (data(trial).data * output(m).betas) + output(m).bias;
        projections(tr).proj = proj;
        
        % Evaluate the projection using the built in, in logistic amounts
        % to the above projection sigmoided
        [~, projections(tr).projeval] = predict(output(m).model, data(trial).data);
        
        % Normalize within trial, old and not used anymore
        projections(tr).projlocalnorm = proj / max(abs(proj));
        
        % Save details
        projections(tr).trialNumber = data(trial).trialNumber;
        projections(tr).label = data(trial).label;
    end
    output(m).projections = projections;
end

if strcmp(method, 'allnorm')
    
    % Get 90th percentile for decoded values across all trials
    % Normalize each trial's projection by this value
    vals = cellfun(@(x) [x.proj], {output.projections}, 'UniformOutput', false);
    vals = [vals{:}];
    normval = prctile(reshape(vals, 1, []), 90);
    for m = 1:length(output)
        for tr = 1:length(output(m).projections)
            output(m).projections(tr).projnorm = output(m).projections(tr).proj / normval;
            % Compute maximum bin and time
%             [~, output(m).projections(tr).maxbin] = max(abs(output(m).projections(tr).projnorm));
%             output(m).projections(tr).maxtime = output(m).tPts(output(m).projections(tr).maxbin);
        end
    end
    
    
elseif strcmp(method, 'normLR')
    
    % Get 90th percentile for decoded values across all trials
    % Normalize each trial's projection by this value, separately for L and R
    conds = unique(cell2mat(cellfun(@(x) [x.label], {output.projections}, 'UniformOutput', false)));
    vals = cellfun(@(x) [x.proj], {output.projections}, 'UniformOutput', false);
    vals = [vals{:}];
    lefts = cell2mat(cellfun(@(x) [x.label], {output.projections}, 'UniformOutput', false)) == conds(1);
    rights = cell2mat(cellfun(@(x) [x.label], {output.projections}, 'UniformOutput', false)) == conds(2);
    normvalleft = -1*prctile(reshape(vals(:,lefts), 1, []), 10); % Flip sign
    normvalright = prctile(reshape(vals(:,rights), 1, []), 90);
    for m = 1:length(output)
        for tr = 1:length(output(m).projections)
            if output(m).projections(tr).label == conds(1)
                output(m).projections(tr).projnorm = output(m).projections(tr).proj / normvalleft;
            else
                output(m).projections(tr).projnorm = output(m).projections(tr).proj / normvalright;
            end
            % Compute maximum bin and time
            [~, output(m).projections(tr).maxbin] = max(abs(output(m).projections(tr).projnorm));
            output(m).projections(tr).maxtime = output(m).tPts(output(m).projections(tr).maxbin);
        end
    end
    
end

end