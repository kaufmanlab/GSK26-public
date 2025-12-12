function ylims = jointsReconPlot(output, joints, field, ylims)
% Plot joint angle time series and their reconstructions

if nargin < 3
    field = 'jointAngles';
end

if nargin < 4
    ylims = zeros(2 * length(joints), 2);
end

reconField = [field 'Recon'];

jointNames = {'SHLDf', 'SHLDa', 'SHLDr', 'ELBOf', 'WRSTf', 'WRSTd', 'WRSTr', ...
    'MCP1f', 'MCP2f','MCP3f', 'MCP4f', 'MCP1a', 'MCP2a', 'MCP3a', 'MCP4a','MCP1o', 'MCP4o', ...
    'P1P2', 'P2P3', 'P3P4', 'PIP1f', 'PIP2f', 'PIP3f', 'PIP4f'};

colors = [[0,0,1];[1,0,0]];
alpha = 0.2;
lw = 0.25;

fig;
tl = tiledlayout(2,length(joints), 'TileSpacing', 'none', 'Padding', 'none');
ax = zeros(2, length(joints));

liftBin = 11;
for row = 1:2
    
    % Set trials
    trials = find([output.outcomes.LR] == row);
    color = colors(row,:);
    
    for col = 1:length(joints)
        % Set axis
        ind = sub2ind([length(joints), 2], col, row);
        ax(row, col) = nexttile(tl,ind);
        axis off
        hold on;
        
        % Plot original
        for trial = trials
            % Plot original
            jointAngle = output.outcomes(trial).data(:, joints(col));
            tPts = (1:size(output.outcomes(trial).data(:, joints(col)),1));
            plot(tPts, jointAngle, 'Color', [0,0,0, alpha], 'LineWidth', lw);
        end
        
        % Plot reconstruction
        for trial = trials
            % Plot reconstruction
            jointAngle = output.outcomes(trial).(reconField)(:, joints(col));
            tPts = (1:size(output.outcomes(trial).(reconField)(:, joints(col)),1));
            plot(tPts, jointAngle, 'Color', [color, alpha], 'LineWidth', lw);
        end
        
        hAx = gca;

        if nargin < 4
            lims = [min([hAx.Children(:).YData]), max([hAx.Children(:).YData])];
        else
            lims = ylims(ind,:);
        end
        ylims(ind, :) = lims;
        
        line([tPts(1),tPts(end)], [0,0], 'Parent', ax(row,col), 'Color', 'k', 'LineStyle', '-')
        
        line([tPts(liftBin),tPts(liftBin)], [lims(1),lims(2)], 'Parent', ax(row,col), 'Color', 'k', 'LineStyle', '--')
        set(hAx, 'YLim', lims)
        
        if row == 1
            title(ax(row, col), jointNames{joints(col)}, 'FontSize', 8, 'FontWeight', 'normal')
        end
        
        if row == 2 && col == length(joints)
            line([tPts(end), tPts(end)], [lims(1) lims(1) + 30], 'Color', 'k');
            
            line([tPts(end-1), tPts(end - 11)], [lims(1) lims(1)], 'Color', 'k');
        end
    end
end


end