function [output, outputPrxDst, outputD2S, outputRes, outputWc, outputWa] = loadDecode(dataPath, mouse, session, kinematicField, neuralField, fitModels)
% Runs all decoding model configurations for one dataset, for specified
% data fields

if nargin < 6
    fitModels = [1,1,1,1,1,1]; % fit all 6 model configurations
end

%% Load preprocessed data
load(sprintf('%s%s_%s_liftLocked', dataPath, mouse, session), 'kinematics', 'neurons', 'M')

% Unified time window for decoding
preT = -100;
postT = 400;
tBins = ismember(M.config.tPts, preT:M.config.tBase:postT);

% Screen to the top 100 ZETA modulated cells, lift modulated only
pvals = min(M.modScores.liftTimeDLC);
[~, roiIdx] = sort(pvals);
ROIs = roiIdx(1:100);

%% Fit Models
if fitModels(1)
    % Decode instantaneous
    output = decode(kinematics, neurons, tBins, ROIs, kinematicField, neuralField);
    % Reconstruct
    % Only do bagged reconstructions for full model
    output = baggedDecode(output, kinematicField);
    % Keep only necessary output fields
    output.outcomes = keepFields(output.outcomes, ...
        {'data', 'jointAnglesRecon', 'jointAnglesReconVE', 'jointAnglesReconVEMed', 'posXYZRecon', 'posXYZ', 'LR', 'locked', 'trialNumber', 'goodDLC'});
else
    output = [];
end

% Run additional decoding models
if fitModels(2)
    % Partial-ing proximal variance off of distal joints
    outputPrxDst = decodePartialPrxDst(kinematics, neurons, tBins, ROIs, kinematicField, neuralField);
    % Remove stored data, do not need for reconstructions
    outputPrxDst = rmfield(outputPrxDst, {'predictors', 'outcomes'});
else
    outputPrxDst = [];
end

if fitModels(3)
    % Partial-ing off distance to the spout from the joint angles
    outputD2S = decodePartialD2S(kinematics, neurons, tBins, ROIs, kinematicField, neuralField);
    % Remove stored data, do not need for reconstructions
    outputD2S = rmfield(outputD2S, {'predictors', 'outcomes'});
else
    outputD2S = [];
end

% Models below were added in review
if fitModels(4)
    % Fit residual models, left and right trials separately
    outputRes = decodeResiduals(kinematics, neurons, tBins, ROIs, kinematicField, neuralField);
    % Remove stored data, do not need for reconstructions
    outputRes.outputL = rmfield(outputRes.outputL, {'predictors', 'outcomes'});
    outputRes.outputR = rmfield(outputRes.outputR, {'predictors', 'outcomes'});
else
    outputRes = struct;
    outputRes.outputL = [];
    outputRes.outputR = [];
end

if fitModels(5)
    % Fit a lagged causal Wiener filter model
    lags = -100:20:0;
    tPts = preT:M.config.tBase:postT;
    outputWc = decodeWiener(kinematics, neurons, tPts, ROIs, lags, kinematicField, neuralField);
    % Remove stored data, do not need for reconstructions
    outputWc = rmfield(outputWc, {'predictors', 'outcomes'});
else
    outputWc = [];
end

if fitModels(6)
    % Fit a lagged acausal Wiener filter model
    lags = -100:20:100;
    tPts = preT:M.config.tBase:postT;
    outputWa = decodeWiener(kinematics, neurons, tPts, ROIs, lags, kinematicField, neuralField);
    % Remove stored data, do not need for reconstructions
    outputWa = rmfield(outputWa, {'predictors', 'outcomes'});
else
    outputWa = [];
end

end