function plotTrajectories(kinematics, plotParams)

% Params
xshift = 20; % offset between L and R trials
spoutCol = [0.5, 0.5, 0.5];

% Make figure
fig;
hA = gca;
axis off
hold on;
hA.View = [-22,4];
axis equal

% R spout
line(hA, [plotParams.spoutPose(1,1) plotParams.spoutPose(1,1) plotParams.spoutPose(2,1) plotParams.spoutPose(2,1)], ...
    [plotParams.spoutPose(1,2) plotParams.spoutPose(1,2) plotParams.spoutPose(2,2) plotParams.spoutPose(2,2)], ...
    [plotParams.spoutPose(1,3) plotParams.spoutPose(1,3) plotParams.spoutPose(2,3) plotParams.spoutPose(2,3)],'LineWidth', plotParams.spoutLineWidth, 'Color', spoutCol);
% L spout
line(hA, [plotParams.spoutPose(3,1) plotParams.spoutPose(3,1) plotParams.spoutPose(4,1) plotParams.spoutPose(4,1)] + xshift, ...
    [plotParams.spoutPose(3,2) plotParams.spoutPose(3,2) plotParams.spoutPose(4,2) plotParams.spoutPose(4,2)], ...
    [plotParams.spoutPose(3,3) plotParams.spoutPose(3,3) plotParams.spoutPose(4,3) plotParams.spoutPose(4,3)],'LineWidth', plotParams.spoutLineWidth, 'Color', spoutCol);

% Trial type colors
colors = [[0,0,1];[1,0,0]];

% Loop over all trials
for tr = 1:length(kinematics)
    % Decide which trial type we are plotting
    if kinematics(tr).LR == 1
        plotParams.traceColors = colors(1,:);
        xoffset = xshift;
    elseif kinematics(tr).LR == 2
        plotParams.traceColors = colors(2,:);
        xoffset = 0;
    end
    
    % Get and plot data
    plotData = permute(mean(kinematics(tr).posXYZ(:,:,1:4),3) + [xoffset, 0, 0], [1, 4, 2, 3]);
    plot3(plotData(:,:,1), plotData(:,:,2), plotData(:,:,3), 'Color', plotParams.traceColors, 'LineWidth', plotParams.traceLineWidth);
    
    % Indicate lift time
    liftBin = find(kinematics(tr).tPts == 0);
    scatter3(hA, plotData(liftBin,:,1), plotData(liftBin,:,2), plotData(liftBin,:,3), 'Marker', '.', 'CData', colormapHSV(plotParams.traceColors, [], [], 0.5), 'SizeData', 200);
    
    % Interpolate and then plot the position at contact
    contactData = interp1(kinematics(tr).tPts, plotData, kinematics(tr).eventInterval, 'linear');
    scatter3(hA, contactData(:,:,1), contactData(:,:,2), contactData(:,:,3), 'Marker', '.', 'CData', colormapHSV(plotParams.traceColors, [], [], 0.5), 'SizeData', 200);
    
end

% Clean up axes
coordAxes(hA, [8, 90, -20], 3, 12, [-1,-1,1])

end