function plotTargetClassifierTimingAll(output)
% Plots distributions of crossing times for classifier projections
% time runs vertically

% Figure
fig;
hold on
axis off
ax = gca;

% Params
bxw = 0.25;
alpha = 0.35;
dotSize = 15;
spacing = [1,1.75];
buff = 2.5;
axlocs = [spacing; spacing + buff; spacing + buff*2; spacing + buff*3; spacing + buff*4];
tPts = output(1).M1(1).tPts;
colors = [[79,178,61];[199,72,149];[128,128,128]]/255;

% Loop over mice
count = 1;
for mouse = output
    
    M1crossings = cell2mat(cellfun(@(x) [x.crosstime], {mouse.M1(1:5).projections}, 'UniformOutput', false));
    S1crossings = cell2mat(cellfun(@(x) [x.crosstime], {mouse.S1(1:5).projections}, 'UniformOutput', false));
    
    violin(ax, M1crossings, [axlocs(count,1), 0], colors(2,:), alpha, dotSize, '', colors(2,:), 18);
    violin(ax, S1crossings, [axlocs(count,2), 0], colors(1,:), alpha, dotSize, '', colors(1,:), 18);
    
    % Test significance
    p = ranksum(M1crossings, S1crossings) % prints to command line
    
    if p < 0.05
        text(mean([axlocs(count,1), axlocs(count,2)]), 500, '*', 'FontSize', 12);
    end
    count = count + 1;
    
    % Print
    fprintf('%s M1: %0.3f ms, S1: %0.3f ms  diff: %0.3f ms p: %0.3f\n', mouse.mouse, nanmedian(M1crossings), nanmedian(S1crossings), nanmedian(M1crossings) - nanmedian(S1crossings), p);
   
end

% Vertical axis
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = [tPts(1) 0 100 200 300 400 tPts(end)];
vaxParams.tickLabels = cellstr(num2str([tPts(1) 0 100 200 300 400 tPts(end)]'));
vaxParams.tickLabelLocations = [tPts(1) 0 100 200 300 400 tPts(end)];
vaxParams.axisOffset = 0;
vaxParams.fontSize = 7;
vaxParams.axisLabel = 'time from cue onset (ms)';
vaxParams.lineThickness = 0.5;
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

% Horizontal axis
ticks = mean(axlocs,2);
for t = 1:length(ticks)
    clear haxParams
    haxParams.axisOrientation = 'h';
    haxParams.tickLocations = [axlocs(t,1) - bxw, axlocs(t,end) + bxw];
    haxParams.tickLabels = {num2str(t)};
    haxParams.tickLabelLocations = ticks(t);
    haxParams.axisOffset = -100;%-0.02;
    haxParams.axisLabelOffset = -100;%-0.02;
    haxParams.fontSize = 7;
    haxParams.invert = 1;
    haxParams.lineThickness = 0.5;
    AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);
    
end

setXYLim(ax,1,1)

end