function plotTargetXTPerformanceAll(outputs)
% Matrix plot for cross time condition decoding performance
% vertical axis is time in trial, horizontal is training time bin

% Figure
fig;
hold on;
axis off;
w = 50;
h = 50;
hspace = 7.5;
wspace = 15;

% Plot line at cue
tPts = -100:10:1000;
bins = linspace(0,w,length(tPts));
cuebin = bins(tPts == 0);

area = 'M1';
% nTrainPeriods x nTimePts x nFolds x nAnimals
data = zeros(length(outputs(1).(area)),length(outputs(1).(area)(1).models(1).performance_all),length(outputs(1).(area)(1).models), length(outputs));
for mouse = 1:length(outputs)
    for m = 1:length(outputs(mouse).(area))
        data(m, :, :, mouse) = cat(1,outputs(mouse).(area)(m).models.performance_all)';
    end
end

widths = [[0 w];[0 w];[0 w];[0 w];[0 w]]; % Vertical columns
heights = [[0 h];[h + hspace h*2 + hspace];[h*2 + hspace*2 h*3 + hspace*2];[h*3 + hspace*3 h*4 + hspace*3];[h*4 + hspace*4 h*5 + hspace*4]];
for mouse = 1:length(outputs)
    % nTimePts x nTrainPeriods, time in trial goes vertically, each column is from a classifier trained on a separate time chunk
    means = mean(data(:,:,:, mouse), 3)';
    imagesc('CData', means, 'XData', widths(mouse,:), 'YData', heights(mouse,:));
    % Horizontal line
    line(widths(mouse,:), [cuebin cuebin] + (h + hspace)*(mouse-1), 'LineStyle', '--', 'Color', [0,0,0], 'LineWidth', 0.5)
    % Vertical line
    line([widths(mouse,1) + w/20 widths(mouse,1) + w/20], heights(mouse,:), 'LineStyle', '--', 'Color', [0,0,0], 'LineWidth', 0.5);
end

area = 'S1';
% nTrainPeriods x nTimePts x nFolds x nAnimals
data = zeros(length(outputs(1).(area)),length(outputs(1).(area)(1).models(1).performance_all),length(outputs(1).(area)(1).models), length(outputs));
for mouse = 1:length(outputs)
    for m = 1:length(outputs(mouse).(area))
        data(m, :, :, mouse) = cat(1,outputs(mouse).(area)(m).models.performance_all)';
    end
end

widths = [[w + wspace w*2 + wspace];[w + wspace w*2 + wspace];[w + wspace w*2 + wspace];[w + wspace w*2 + wspace];[w + wspace w*2 + wspace];]; % Vertical columns
heights = [[0 h];[h + hspace h*2 + hspace];[h*2 + hspace*2 h*3 + hspace*2];[h*3 + hspace*3 h*4 + hspace*3];[h*4 + hspace*4 h*5 + hspace*4]];
for mouse = 1:length(outputs)
    means = mean(data(:,:,:, mouse), 3)';
    imagesc('CData', means, 'XData', widths(mouse,:), 'YData', heights(mouse,:));
    % Horizontal line for cue
    line(widths(mouse,:), [cuebin cuebin] + (h + hspace)*(mouse-1), 'LineStyle', '--', 'Color', [0,0,0], 'LineWidth', 0.5);
    % Vertical line
    line([widths(mouse,1) + w/20 widths(mouse,1) + w/20], heights(mouse,:), 'LineStyle', '--', 'Color', [0,0,0], 'LineWidth', 0.5);
end

% Labels
text(-8, cuebin, 'cue', 'FontSize', 7, 'HorizontalAlignment', 'center')
text(w/20, -2, 'cue', 'FontSize', 7, 'HorizontalAlignment', 'center')
line([-4, -4], [bins(end-10) bins(end)], 'Color', [0,0,0], 'LineStyle', '-', 'LineWidth', 2)
text(-8, mean([bins(end-10) bins(end)]), '100 ms', 'FontSize', 7, 'HorizontalAlignment', 'center')
text(25, h*5 + hspace*4 + hspace, 'M1', 'FontSize', 10, 'HorizontalAlignment', 'center')
text(85, h*5 + hspace*4 + hspace, 'S1', 'FontSize', 10, 'HorizontalAlignment', 'center')
text(-8, h*2.5 + hspace*2, 'testing bin (10 ms)', 'FontSize', 7, 'HorizontalAlignment', 'center', 'Rotation', 90)
text(w*2.5 + wspace*2, 8, 'training epoch (90 ms)', 'FontSize', 7, 'HorizontalAlignment', 'center', 'Rotation', 90)

% Colorbar
colormap parula;
set(gca, 'YLim', [-15  300])
cb = colorbar('SouthOutside', 'Box', 'off', 'FontSize', 7);
cb.Ticks = round(cb.Limits);
cb.Position = [0.6 0.05 0.3, 0.025];

end