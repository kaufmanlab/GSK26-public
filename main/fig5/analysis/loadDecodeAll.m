function outputs = loadDecodeAll(dataPath, datasets, kinematicField, neuralField, fitModels)
% Wrapper over loadDecode to run all models for all datasets

if nargin < 5
    fitModels = [1,1,1,1,1,1]; % fit all 6 model configurations
end

% Loop
outputs = struct('mouse', cellfun(@(x) x{1}, datasets, 'UniformOutput', false));
for dataset = datasets
    mouse = dataset{1}{1};
    session = dataset{1}{2};
    fprintf('Running %s %s\n', mouse, session);
    
    % Load and decode all model configurations
    [output, outputPrxDst, outputD2S, outputRes, outputWc, outputWa] = loadDecode(dataPath, mouse, session, kinematicField, neuralField, fitModels);
    
    % Store (weird indexing based on loop iteration scheme)
    outputs(strcmp({outputs(:).mouse}, mouse)).output = output;
    outputs(strcmp({outputs(:).mouse}, mouse)).outputPrxDst = outputPrxDst;
    outputs(strcmp({outputs(:).mouse}, mouse)).outputD2S = outputD2S;
    outputs(strcmp({outputs(:).mouse}, mouse)).outputResL = outputRes.outputL;
    outputs(strcmp({outputs(:).mouse}, mouse)).outputResR = outputRes.outputR;
    outputs(strcmp({outputs(:).mouse}, mouse)).outputWc = outputWc;
    outputs(strcmp({outputs(:).mouse}, mouse)).outputWa = outputWa;
end

end