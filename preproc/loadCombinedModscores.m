function modScores = loadCombinedModscores(datasets, dataPath, eventName)

% Loop over datasets, loading and combining the modScores from the M
% structs
modScores = [];
for dataset = datasets
    mouse = dataset{1}{1};
    session = dataset{1}{2};
    [~, M, ~] = loadData(mouse, session, 'R', 'DLC3', dataPath);
    modScores = cat(2, modScores, M.modScores.(eventName));
end

end