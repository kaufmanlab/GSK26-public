function plotVEvsVar(outputs, field)

% Colormap
proxcol = [215, 15, 175]/255;
distcol = [255, 160, 25]/255;

% Figure
fig;
hold on
axis off

% Params
markers = {'s', 'x', '+', '*', 'o'};
kinematicField = 'data';

jointsP = 1:7;
jointsD = 8:24;
count = 1;
for output = outputs
    marker = markers{count};
    % Plot each joint's median as a scatter
    for j = jointsP
        veP = output.(field).VEs(:,j);
        varP = zeros(size(veP,1),1);
        for f = 1:size(varP,1)
            vars = var(cat(1, output.(field).outcomes(output.(field).testInds{f}).(kinematicField)));
            varP(f) = vars(j);
        end
        scatter(varP, veP, 'SizeData', 5, 'CData', proxcol, 'Marker', marker, 'MarkerFaceColor', proxcol, 'MarkerEdgeColor', proxcol);
    end
    % Then plot median as a line
    
    % Plot each joint's median as a scatter
    for j = jointsD
        veD = output.(field).VEs(:,j);
        varD = zeros(size(veD,1),1);
        for f = 1:size(varD,1)
            vars = var(cat(1, output.(field).outcomes(output.(field).testInds{f}).(kinematicField)));
            varD(f) = vars(j);
        end
        scatter(varD, veD, 'SizeData', 5, 'CData', distcol, 'Marker', marker, 'MarkerFaceColor', distcol, 'MarkerEdgeColor', distcol);
    end
    
    count = count + 1;
end

% Vertical axis
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = linspace(0,1,5);
vaxParams.tickLabels = arrayfun(@(x) cellstr(num2str(x)), linspace(0,1,5));
vaxParams.tickLabelLocations = linspace(0,1,5);
vaxParams.axisOffset = -100;
vaxParams.fontSize = 8;
vaxParams.axisLabel = 'variance explained';
vaxParams.lineThickness = 0.5;
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

% Horizontal axis
haxParams.axisOrientation = 'h';
haxParams.tickLocations = linspace(0,2000,5);
haxParams.tickLabels = arrayfun(@(x) cellstr(num2str(x)), linspace(0,2000,5));
haxParams.tickLabelLocations = linspace(0,2000,5);
haxParams.axisOffset = -0.1;
haxParams.fontSize = 8;
haxParams.axisLabel = 'variance';
haxParams.lineThickness = 0.5;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);