function hSkeleton = drawSkeleton(hA, data, config, hSkeleton)
% data is arranged in a 3D array with the first dimension being the number
% of unique skeletons to plot, the second being the XY or XYZ values,
% and the third being the number of markers to create the skeleton out of

% Get the skeleton links we want to plot
links2Plot = ismember(config.skeleton2Plot, config.markers2Plot);
config.skeleton = config.skeleton2Plot(bsxfun(@and, links2Plot(:,1), links2Plot(:,2)), :);

% If the third dimension has only two indices, we want to plot 2D data, so
% we fill the third index with NaNs to preserve later plot3 calls
if size(data, 2) == 2
    data(:,3,:) = 0;
end

% Initialize arrays of object handles
if nargin < 4
    hSkeleton = zeros(size(data,1), size(config.skeleton,1));
end

% Make config.markerColors the correct size if it isn't passed in as such
if size(data,1) > 1 && size(data,1) > 1
   config.linkColors = repmat(config.linkColors, 1, 1, size(data,1));
end

% Nested plotting loops
for skel = 1:size(data,1)
    for link = 1:size(config.skeleton,1)
        
        x = [data(skel, 1, config.skeleton(link,1))'; data(skel, 1, config.skeleton(link,2))];
        y = [data(skel, 2, config.skeleton(link,1))'; data(skel, 2, config.skeleton(link,2))];
        z = [data(skel, 3, config.skeleton(link,1))'; data(skel, 3, config.skeleton(link,2))];
        
        linkCol = config.linkColors(link, :, skel);
        
        if nargin < 4
            hSkeleton(skel,link) = line(hA, x, y, z, ...
                'LineWidth', config.linkLineWidth, 'Color', linkCol, 'Tag', sprintf('link%i',link));
        else
            if ishandle(hSkeleton(skel, link))
                set(hSkeleton(skel, link), {'XData', 'YData', 'ZData', 'Color'}, {x,y,z, linkCol});
            end
        end
    end
end
end