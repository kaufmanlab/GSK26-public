function plotZETAScores(modScores, thresh)

% Scatter plot containing cells plotted by log(p-value)
thresh = log10(thresh);

% Get logs of p-values for left and right
pval_L = log10(modScores(1,:));
pval_R = log10(modScores(2,:));

% Set NaN values to 0
pval_L(isnan(pval_L)) = 0;
pval_R(isnan(pval_R)) = 0;
pval_L(isinf(pval_L)) = min(pval_L(~isinf(pval_L)));
pval_R(isinf(pval_R)) = min(pval_R(~isinf(pval_R)));    
pval_all = [pval_R, pval_L];

% Normalize values for colormap
greyval = 0.4;
normpval_L = normalize(abs(pval_L), 'range', [greyval,1]);
normpval_R = normalize(abs(pval_R), 'range', [greyval,1]);
scaleval_L = -normalize(abs(pval_L), 'range', [-1,0]);
scaleval_R = -normalize(abs(pval_R), 'range', [-1,0]);

% Get coloring for each cell
% Red to fuschia to blue, scaled by pvalue for each condition
% Red is right tuned, blue is left tuned, fuschia tuned to both
% Grey is not modulated
colors = zeros(length(pval_L),3);
modulated = ones(length(pval_L),1);
for roi = 1:length(colors)
   
    if pval_L(roi) < thresh && pval_R(roi) < thresh % Both tuned
        colors(roi,:) = [normpval_R(roi), 0, normpval_L(roi)] + ((scaleval_L(roi) + scaleval_R(roi))/2)*[0, greyval, 0];
    elseif pval_L(roi) < thresh && pval_R(roi) > thresh % L tuned only
        colors(roi,:) = [0, 0, normpval_L(roi)] + scaleval_L(roi)*[greyval, greyval, 0];
    elseif pval_L(roi) > thresh && pval_R(roi) < thresh % R tuned only
        colors(roi,:) = [normpval_R(roi), 0, 0] + scaleval_R(roi)*[0, greyval, greyval];
    else
        colors(roi,:) = [0.5, 0.5, 0.5];
        modulated(roi) = 0;
    end
end

% Figure
fig;
hold on;
axis equal
axis off
set(gca,'Ydir','reverse')
set(gca,'Xdir','reverse')

% Scatter points
scatter(pval_R, pval_L, 0.5, colors, 'filled');

% Set limits
axmin = -1;
axmax = -10;
% xlim([axmax axmin])
% ylim([axmax axmin]) 

% Plot unity line
line([0,-10], [0, -10], 'LineWidth', 0.5, 'LineStyle', '--', 'Color', [0 0 0])
% Plot threshold lines
line([thresh, thresh], [axmin, thresh], 'LineWidth', 0.5, 'LineStyle', '-', 'Color', [0 0 0]);
line([axmin, thresh], [thresh, thresh], 'LineWidth', 0.5, 'LineStyle', '-', 'Color', [0 0 0]);

% Horizontal axis
ticks = linspace(0, -10, 5);
haxParams.axisOrientation = 'h';
haxParams.tickLocations = ticks;
haxParams.tickLabels = arrayfun(@(x) cellstr(num2str(x)), ticks);
haxParams.tickLabelLocations = ticks;
haxParams.tickLabelOffset = -0.5;
haxParams.axisOffset = 0.5;
haxParams.fontSize = 6;
haxParams.invert = 0;
haxParams.invertTicks = 1;
haxParams.axisLabel = 'right log(p-value)';
haxParams.axisLabelOffset = -3;
haxParams.lineThickness = 0.5;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);

% Vertical axis
ticks = linspace(0, -10, 5);
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = ticks;
vaxParams.tickLabels = arrayfun(@(x) cellstr(num2str(x)), ticks);
vaxParams.tickLabelLocations = ticks;
vaxParams.tickLabelOffset = -0.5;
vaxParams.axisOffset = 0.5;
vaxParams.fontSize = 6;
vaxParams.invert = 0;
vaxParams.invertTicks = 1;
vaxParams.axisLabel = 'left log(p-value)';
vaxParams.axisLabelOffset = -4;
vaxParams.lineThickness = 0.5;
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

% Title
text(axmax, axmax, sprintf('%i/%i ROIs modulated', sum(modulated), length(modulated)), 'HorizontalAlignment', 'center', 'FontSize', 6);

end