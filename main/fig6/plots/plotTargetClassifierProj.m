function plotTargetClassifierProj(output, field, plotCrosstimes)
% Plots projection traces like in Kaufman et al 2015 eLife
% time runs vertically

if nargin < 2
    field = 'proj'; 
end

if nargin < 3
    plotCrosstimes = 0;
end

% Figure
fig;
hold on;
axis off

% Plot traces
lw = 0.25;
scale = 1;
alpha = 0.35;
for model = 1:5
    for tr = 1:length(output(model).projections)
        tPts = output(model).tPts;
        if output(model).projections(tr).label == 1
            color = [0,0,1];
        else
            color = [1,0,0];
        end
        proj = output(model).projections(tr).(field);
        plot(proj, tPts, 'Color', [colormapHSV(color, [], [], scale), alpha], 'LineStyle', '-', 'LineWidth', lw);
    end
end

ax = gca;
minXVal = min(reshape(cell2mat(arrayfun(@(x) x.XData, [ax.Children], 'UniformOutput', 0)),1,[]));

% For plotting crosstimes for debugging
if plotCrosstimes
    for model = 1:5
        for tr = 1:length(output(model).projections)
            tPts = output(model).tPts;
            if output(model).projections(tr).label == 1
                color = [0,0,1];
            else
                color = [1,0,0];
            end
            if isfield(output(model).projections(tr), 'beyondbin')
                if ~isnan(output(model).projections(tr).beyondbin)
                    %         interp1(tPts', output(model).projections(tr).projnorm, output(model).projections(tr).crosstime)
                    proj = output(model).projections(tr).(field);
                    scatter(proj(output(model).projections(tr).beyondbin), tPts(output(model).projections(tr).beyondbin), 'CData', colormapHSV(color, [], [], 0.5), 'SizeData', 30, 'Marker', '.');
                end
            end
        end
    end
end

% Horizontal axis
haxParams.axisOrientation = 'h';
haxParams.tickLocations = [-1 0 1];
haxParams.tickLabels = {'-1', '0', '1'};
haxParams.tickLabelLocations = [-1 0 1];
haxParams.axisOffset = output(1).tPts(1) - 10;
haxParams.fontSize = 7;
haxParams.axisLabel = 'decoded choice (a.u.)';
haxParams.lineThickness = 0.5;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);

% Vertical axis
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = [output(1).tPts(1) 0 output(1).tPts(end)];
vaxParams.tickLabels = cellstr(num2str([output(1).tPts(1) 0 output(1).tPts(end)]'));
vaxParams.tickLabelLocations = [output(1).tPts(1) 0 output(1).tPts(end)];
vaxParams.axisOffset = 1.1*minXVal;
vaxParams.fontSize = 7;
vaxParams.axisLabel = 'time from cue onset (ms)';
vaxParams.lineThickness = 0.5;
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

% Pretty up axes and layout
setXYLim(gca, 1, 1)

% Title
text(0, 0, sprintf('%0.1f%%', median([output.performance])), 'HorizontalAlignment', 'center', 'FontSize', 8)

end