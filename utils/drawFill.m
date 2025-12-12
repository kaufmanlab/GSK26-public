function hFill = drawFill(hA, data, config, hFill)
% data is arranged in a 3D array with the first dimension being the number
% of fills to plot, the second being the dimensions (XY or XYZ), and the
% third being the number of vertices

dataSize = size(data);

% Initialize arrays of object handles
if nargin < 4
    hFill = zeros(dataSize(1),1);
end

% If the third dimension has only two indices, we want to plot 2D fill, so
% we fill the third index with NaNs to preserve later plot3 calls
if dataSize(2) == 2
    data(:,3,:) = 0;
end

% Nested plotting loops
% Loop over the fills
for f = 1:size(data,1)
    
    x = squeeze(data(f, 1, config.markers2Fill));
    y = squeeze(data(f, 2, config.markers2Fill));
    z = squeeze(data(f, 3, config.markers2Fill));
    
    cmapPatch = repmat(config.fillColor, length(config.markers2Fill)+1,1);
    
    if nargin < 4
        hFill(f) = patch('Parent', hA, 'Faces', [1:length(x), 1], 'Vertices', [[x, y, z]; NaN(1,3)], 'FaceVertexCData', cmapPatch, 'FaceColor', config.fillColor, 'EdgeColor','interp', ...
            'FaceAlpha', config.fillAlpha, 'EdgeAlpha', config.fillAlpha, ...
            'LineWidth', config.traceLineWidth, 'LineStyle', config.traceLineStyle);
        
    else
        setData = {[1:length(x), 1], [[x, y, z]; NaN(1,3)], cmapPatch, config.fillColor, config.traceLineWidth, config.traceLineWidth, config.fillAlpha, config.fillAlpha};
        setNames = {'Faces', 'Vertices', 'FaceVertexCData', 'FaceColor', 'LineWidth', 'MarkerSize', 'FaceAlpha', 'EdgeAlpha'};
        if ishandle(hFill(f))
            set(hFill, setNames, setData);
        end
    end
end
end
