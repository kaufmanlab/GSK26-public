function [subsequences, lengths] = findSubsequences(sequence)
% Finds sequences of 1 in binary vector of 1s and 0s

% Assign initial and allocate
subsequences = {};
subseqN = 0;
inSubsequence = false;
% Loop over idx
for idx = 1:length(sequence)
    % Current value is 1 and idx is not in a subsequence of 1s
    if sequence(idx) && ~inSubsequence
        % If so, increment discovered subsequences
        subseqN = subseqN + 1;
        % Flag
        inSubsequence = 1;
        % Save
        subsequences{subseqN} = idx;
        % Current value is 1 and idx is in a subsequence of 1s, append
    elseif sequence(idx) && inSubsequence
        subsequences{subseqN} = [subsequences{subseqN} idx];
        % Current value is 0 and idx is in a subsequence of 1s, break
    elseif ~sequence(idx) && inSubsequence
        inSubsequence = false;
    end
end

% Get sequence lengths
lengths = cell2mat(cellfun(@(x) length(x), subsequences, 'UniformOutput', false));
end