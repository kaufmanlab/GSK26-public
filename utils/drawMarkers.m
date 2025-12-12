function hMarkers = drawMarkers(hA, data, config, hMarkers)
% data is arranged in a 3D array with the first dimension being the number
% of unique skeletons to plot the second being the XY or XYZ values,
% and the third being the number of markers to create the skeleton out of

% If the third dimension has only two indices, we want to plot 2D data, so
% we fill the third index with NaNs to preserve later plot3 calls
if size(data, 2) == 2
    data(:,3,:) = 0;
end

% Initialize arrays of object handles
if nargin < 4
    hMarkers = zeros(size(data,1), size(data,3));
end

% Get only the markers we want to plot
% as written, this will cause problems if markers to update do not match
% the markers made in original call to produce hMarkers
data = data(:,:,config.markers2Plot);

% Make config.markerColors the correct size if it isn't passed in as such
if size(data,1) > 1 && size(data,1) > 1
   config.markerColors = repmat(config.markerColors, 1, 1, size(data,1));
end

% Nested plotting loops
for skel = 1:size(data,1)
    for marker = 1:size(data,3)
        
        x = data(skel, 1, marker);
        y = data(skel, 2, marker);
        z = data(skel, 3, marker);
        
        if nargin < 4
            hMarkers(skel, marker) = line(hA, ...
                x, ...
                y, ...
                z, ...
                'Marker', '.', 'MarkerSize', config.markerSizes(marker), ...
                'MarkerEdgeColor', config.markerColors(marker, :, skel), ...
                'MarkerFaceColor', config.markerColors(marker, :, skel), 'Tag', sprintf('marker%i',marker));
        else
            if ishandle(hMarkers(skel, marker))
                set(hMarkers(skel, marker), ...
                    {'XData', 'YData', 'ZData', 'MarkerEdgeColor', 'MarkerFaceColor'}, ...
                    {x, y, z, config.markerColors(marker, :, skel), config.markerColors(marker, :, skel)});
            end
        end
        
    end
    
end
end