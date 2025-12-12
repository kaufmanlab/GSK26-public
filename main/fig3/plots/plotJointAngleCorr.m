function plotJointAngleCorr(kinematicsAll, field)

% Correlation matrices grid layout
fig;
hold on;
axis off
axis equal

% Params
cmap = diverging_map(linspace(0,1,20), colormapHSV([255,225,0]/255, [], [], 0.8), colormapHSV([0, 212, 220]/255, [], [], 0.8));
height = 50;
width = 50;
space = 15;
heights = [[height 0];[height 0];[height 0];[-space -height - space];[-space -height - space]]; % Second row below first
widths = [[0 width];[width + space width*2 + space];[width*2 + space*2 width*3 + space*2];[width/2 + space/2 width/2 + width + space/2];[width/2 + width + space*1.5 width/2 + width*2 + space*1.5]];

% Loop over mice
mice = unique({kinematicsAll.animalID});
for m = 1:length(mice)
    
    % Get trials for this mouse
    trials = arrayfun(@(x) strcmp(x.animalID, mice{m}), kinematicsAll);
    
    % Get data
    jointsMat = cat(1,kinematicsAll(trials).(field));
    
    % Exclude bins with spout contact
    contactBins = cat(2,kinematicsAll(trials).contactBins)';
    jointsMat = jointsMat(~contactBins, :);
    
    % Compute correlations
    C = corrcoef(jointsMat);
    
    % Plot correlation matrix
    imagesc('CData', C, 'XData', widths(m,:), 'YData', heights(m,:));
end

colormap(cmap)
caxis([-1 1])
end