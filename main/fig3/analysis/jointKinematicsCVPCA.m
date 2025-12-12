function [lossTests, lossSEMs] = jointKinematicsCVPCA(kinematicsAll, maxDims, nLabels)
% Computes cross validated PCA on joint angles and velocities

if nargin < 3
    nLabels = 5;
end

if nargin < 2
    maxDims = 16;
end

% Params
mice = unique({kinematicsAll.animalID});
lossTests = zeros(length(mice),maxDims,2);
lossSEMs = zeros(length(mice),maxDims,2);
tPts = -100:10:400;

mice = unique({kinematicsAll.animalID});
for m = 1:length(mice)
    
    % Get trials for this mouse
    trials = arrayfun(@(x) strcmp(x.animalID, mice{m}), kinematicsAll);
    kinematics = kinematicsAll(trials);
    
    dataFields = {'jointAngles'};
    dataMat = getDataMatrix(kinematics, dataFields);
    
    labels = reshape(randi(nLabels, length(dataMat)/length(tPts),1)'.*ones(length(tPts),1), length(dataMat), []); % trials
    
    % Exclude contact bins
    contactBins = cat(2,kinematics.contactBins)';
    dataMat = dataMat(~contactBins, :);
    labels = labels(~contactBins);
    
    dataMat = dataMat ./ std(dataMat);
    
    [~, lossTests(m,:,1), lossSEMs(m,:,1), ~] = crossvalPCAYu(dataMat, labels, maxDims);
    
    dataFields = {'jointVelocities'};
    dataMat = getDataMatrix(kinematics, dataFields);
    
    labels = reshape(randi(nLabels, length(dataMat)/length(tPts),1)'.*ones(length(tPts),1), length(dataMat), []); % trials
    
    % Exclude contact bins
    dataMat = dataMat(~contactBins, :);
    labels = labels(~contactBins);
    
    dataMat = dataMat ./ std(dataMat);
        
    [~, lossTests(m,:,2), lossSEMs(m,:,2), ~] = crossvalPCAYu(dataMat, labels, maxDims);
    
end

end

function dataMat = getDataMatrix(data, dataFields, shape)

% Get data matrices for each trial, made of our desired datafields
for tr = 1:length(data)
    
    dataTrial = cellfun(@(fieldName) vertcat(data(tr).(fieldName)), dataFields, 'UniformOutput', false);
    % Some dataFields are 3D, reshape them to 2
    for f = 1:length(dataFields)
        if length(size(dataTrial{f})) > 2
            if shape == 2
                dataTrial{f} = reshape(dataTrial{f}, [], size(dataTrial{f},3));
            else
                dataTrial{f} = reshape(dataTrial{f}, size(dataTrial{f},1), []);
            end
        end
    end
    data(tr).allData = horzcat(dataTrial{:});
end

dataMat = cat(1, data(:).allData);

end