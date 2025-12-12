function outputs = loadClassifierAll(dataPath, datasets, model)
% Wrapper over load---Classifier scripts to run models for all datasets

% Loop
outputs = struct('mouse', cellfun(@(x) x{1}, datasets, 'UniformOutput', false));
for dataset = datasets
    % Requires combined M1 and S1 struct, different from regression function
    mouse = dataset{1}{1};
    sessionM1 = dataset{1}{2};
    sessionS1 = dataset{1}{3};
    
    % Load and classify both sessions
    fprintf('Running %s %s...', mouse, sessionM1);
    outputM1 = loadClassifier(dataPath, mouse, sessionM1, model);
    fprintf('and %s\n', sessionS1);
    outputS1 = loadClassifier(dataPath, mouse, sessionS1, model);
    
    % Store (weird indexing based on loop iteration scheme)
    outputs(strcmp({outputs(:).mouse}, mouse)).M1 = outputM1;
    outputs(strcmp({outputs(:).mouse}, mouse)).S1 = outputS1;
end

end

function output = loadClassifier(dataPath, mouse, session, model)
switch model
    case 'target'
        output = loadTargetClassifier(dataPath, mouse, session);
    case 'RT'
        output = loadRTClassifier(dataPath, mouse, session);
    case 'targetXT'
        output = loadTargetXTClassifier(dataPath, mouse, session);
    case 'targetPartial'
        output = loadTargetPartialClassifier(dataPath, mouse, session);
end
end