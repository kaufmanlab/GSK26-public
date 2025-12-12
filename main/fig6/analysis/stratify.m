function [keptIdx, droppedIdx] = stratify(labels)

    % Stratifies a set of 2-class labels
    % Returns the indices for the stratified subset in keptIdx, and the
    % remainder in droppedIdx
    % Does so by reducing the number of labels in the larger group to match
    % the smaller group
    
    ulabels = unique(labels);
    if length(ulabels) < 2
        disp(ulabels)
        error('Need 2 unique labels to binary stratify')
    end
    group1Idx = find(labels == ulabels(1));
    group2Idx = find(labels == ulabels(2));
    groupIdx = {group1Idx, group2Idx};
    
    % Get group sizes
    groupSizes = [length(group1Idx), length(group2Idx)];
    % If they are already the same, do nothing
    if groupSizes(1) ~= groupSizes(2)
        [~, largerGroup] = max(groupSizes);
        [~, smallerGroup] = min(groupSizes);
        
        % Get indices based on group size
        smallerGroupIdx = groupIdx{smallerGroup};
        largerGroupIdx = groupIdx{largerGroup};
        % Permute their order
        largerGroupIdx = largerGroupIdx(randperm(length(largerGroupIdx)));
        % Discard all indices past the size of the smaller group
        keptLargerGroupIdx = largerGroupIdx(1:length(smallerGroupIdx));
        droppedIdx = largerGroupIdx(length(smallerGroupIdx)+1:end);
        % Return combination of smaller and subsampled larger indices
        keptIdx = sort([smallerGroupIdx; keptLargerGroupIdx]);
    else
        keptIdx = 1:length(labels);
        droppedIdx = [];
    end
    
end