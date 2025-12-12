function hTrace = drawTrace(hA, data, config, hTrace)
% data is arranged in a 4D array with the first dimension being the number
% of frames to plot, the second being the number of trace groupings, the
% third being the XY or XYZ values, and the fourth being the number of
% traces

dataSize = size(data);
% fprintf('dataSize %i\n', dataSize');

% Initialize arrays of object handles
if nargin < 4
    hTrace = zeros(dataSize([1 2 end]));
end

% Nested plotting loops
% Loop over the groups (usually one specific paw per group)
% Then loop over the traces in each group
for grp = 1:size(data,2)
    for trace = 1:size(data,4)

        x = data(:, grp, 1, trace);
        y = data(:, grp, 2, trace);
        z = data(:, grp, 3, trace);
        
        if size(config.traceColors,1) > 1 && ~strcmp(config.traceType, 'colorWithTime')
            traceCol = squeeze(config.traceColors(trace,1:3,grp));
        else
            traceCol = config.traceColors(1,1:3);
        end
        
        if nargin < 4
            if strcmp(config.traceType, 'scatter')
                
                if size(config.traceColors,1) ~= length(x)
                    config.traceColors = repmat(config.traceColors(1,:), length(x), 1);
                end
                
                hTrace(:,grp,trace) = scatter3(hA, x, y, z, ...
                    'Marker', config.traceLineStyle, ...
                    'SizeData', config.traceLineWidth, ...
                    'LineWidth', config.traceLineWidth, ...
                    'MarkerEdgeAlpha', config.traceAlpha(trace), ...
                    'MarkerFaceAlpha', config.traceAlpha(trace), ...
                    'CData', traceCol);
                
            else
                if strcmp(config.traceType, 'colorWithTime')
                    cmapPatch = [config.traceColors; NaN(1,3)];
                else
                    cmapPatch = [repmat(traceCol, length(x), 1); NaN(1,3)];
                end
                
                hTrace(:,grp,trace) = patch('Faces', 1:(length(x) + 1), ...
                    'Vertices', [[x, y, z]; NaN(1,3)], 'FaceVertexCData', cmapPatch, ...
                    'Parent', hA, 'FaceColor','none','EdgeColor','interp', ...
                    'FaceAlpha', config.traceAlpha(trace), 'EdgeAlpha', config.traceAlpha(trace), ...
                    'LineWidth', config.traceLineWidth, 'LineStyle', config.traceLineStyle);
                
            end
        else
            if strcmp(config.traceType, 'scatter')
                if size(config.traceColors,1) ~= length(x)
                    config.traceColors = repmat(config.traceColors(1,:), length(x), 1);
                end
                setData = {x,y,z, config.cmap, config.traceAlpha(trace), config.traceAlpha(trace), config.traceLineWidth};
                setNames = {'XData', 'YData', 'ZData', 'CData', 'MarkerEdgeAlpha', 'MarkerFaceAlpha', 'LineWidth'};
                
            else
                if size(config.traceColors,1) ~= length(x)
                    traceColors = repmat(traceCol, length(x), 1);
                end
                setData = {1:length(x) + 1, [[x, y, z]; NaN(1,3)], [traceColors; NaN(1,3)], config.traceLineWidth, config.traceLineWidth, config.traceAlpha(trace), config.traceAlpha(trace)};
                setNames = {'Faces', 'Vertices', 'FaceVertexCData', 'LineWidth', 'MarkerSize', 'FaceAlpha', 'EdgeAlpha'};
                
            end
            if ishandle(hTrace(:, grp, trace))
                set(hTrace(:, grp, trace), setNames, setData);
            end
        end
    end
end
end

%% OLD CODE
% These lines can be used to plot lines with colors that vary over the
% length, currently using patch instead
%                 hTrace(:,grp,trace) = plot3(hA, x, y, z, ...
%                     'Marker', '.', ...
%                     'LineWidth', config.traceLineWidth, ...
%                     'LineStyle', config.traceLineStyle, ...
%                     'MarkerSize', config.traceLineWidth, ...
%                     'Color', traceCol);