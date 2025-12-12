function [data, V, ve] = pca4Regression(data, nPCs, rotate, denoise, meanSubtract)

% data is a struct of matrices in the field "data", each matrix is
% observations x variables

nChunks = length(data);
dataMat = vertcat(data.data);
nCols = size(dataMat, 2);

if nPCs < 1 % accept a fractional percentage of total number of variables
    nPCs = floor(nPCs*nCols);
end

if nPCs == 0 % enter 0 to use all PCs
    nPCs = nCols;
end

if nargin < 3
    rotate = 0;
end

if nargin < 4
    denoise = 0; % format data for PC regression, otherwise PCA to denoise
end

if nargin < 5
    meanSubtract = 0;
end

% Do PCA
% No mean subtraction beforehand
if meanSubtract
    mn = mean(dataMat);
%     dataMat = (dataMat - mn) ./ std(dataMat);
    ranges = range(dataMat) + (10 * 10 / 1000);
    dataMat = (dataMat - mn) ./ ranges;
end
[V,US,ve] = pca(dataMat); % columns of V are PCs (dimensions)

% Reconstruct mean centered data
if denoise % reconstruct data from fewer PCs
    dataMat = US(:,1:nPCs)*V(:,1:nPCs)';
else % use raw PC scores (projection of data on PCs)
    dataMat = US(:,1:nPCs);
end

% Subselect to only used PCs
V = V(:,1:nPCs);

if rotate
    % Rotate the data by a random matrix
    [rot, ~] = qr(randn(nPCs));
    dataMat = dataMat * rot;
    V = V * rot;
end

% Chunkify and reassign to struct
cChunkSizes = [0 cumsum(cellfun(@(x) size(x,1), {data.data}))];
for chunk = 1:nChunks
    data(chunk).originalData = data(chunk).data;
    data(chunk).data = dataMat(cChunkSizes(chunk)+1:cChunkSizes(chunk+1),:);
end


