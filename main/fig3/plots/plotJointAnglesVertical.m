function plotJointAnglesVertical(kinematics, joints)
% Plots the time series of a specified set of joint angles

% Figure
fig;
axis off
hold on;

% Params
ntPts = length(kinematics(1).tPts);
liftBin = find(kinematics(1).tPts == 0);
tPts = 1:length(kinematics(1).tPts);
alpha = 0.2;
lw = 0.5;
yspace = -30;
xspace = 3;
xoffset = ntPts + xspace;
jointNames = {'SHLDf', 'SHLDa', 'SHLDr', 'ELBOf', 'WRSTf', 'WRSTd', 'WRSTr', ...
    'MCP1f', 'MCP2f','MCP3f', 'MCP4f', 'MCP1a', 'MCP2a', 'MCP3a', 'MCP4a','MCP1o', 'MCP4o', ...
    'P1P2', 'P2P3', 'P3P4', 'PIP1f', 'PIP2f', 'PIP3f', 'PIP4f', };

% Loop over specified joint angles
for row = 1:length(joints)
        
        % Left
        trialsL = find([kinematics.LR] == 1);
        dataL = cat(3,kinematics(trialsL).jointAngles);
        dataL = squeeze(dataL(:,joints(row),:));
        
        % Right
        trialsR = find([kinematics.LR] == 2);
        dataR = cat(3,kinematics(trialsR).jointAngles);
        dataR = squeeze(dataR(:,joints(row),:));
        
        % Get limits for lines
        lims = [min([dataL(:); dataR(:)]), max([dataL(:); dataR(:)])];
        
        % Get yoffset
        if row == 1
            yoffset = 0;
        else
            yoffset = -abs(lims(2) - prevmin) + yspace;
        end
        
        % Plot Lefts
        plot(repmat(tPts', 1, length(trialsL)), yoffset + dataL, 'Color', [0,0,1,alpha], 'LineWidth', lw);
        
        % Plot Rights
        plot(xoffset + repmat(tPts', 1, length(trialsR)), yoffset + dataR, 'Color', [1,0,0,alpha], 'LineWidth', lw);
        
        
        % Left lines
        line([tPts(1), tPts(end)], yoffset + [0,0], 'Color', 'k', 'LineStyle', '--')
        line([tPts(liftBin), tPts(liftBin)], yoffset + [lims(1), lims(2)], 'Color', 'k', 'LineStyle', '--')
        
        % Right lines
        line(xoffset + [tPts(1), tPts(end)], yoffset + [0,0], 'Color', 'k', 'LineStyle', '--')
        line(xoffset + [tPts(liftBin), tPts(liftBin)], yoffset + [lims(1), lims(2)], 'Color', 'k', 'LineStyle', '--')
        prevmin = lims(1) + yoffset;
        
        % Titles
        text(tPts(end), lims(2) + yoffset, jointNames{joints(row)}, 'FontName', 'Helvetica Neue', 'FontSize', 12, 'FontWeight', 'normal', 'HorizontalAlignment', 'center')
        
        if row == length(joints)
            line(xoffset + [tPts(end), tPts(end)], yoffset + [lims(1) lims(1) + 30], 'Color', 'k');

            line(xoffset + [tPts(end-1), tPts(end - 11)], yoffset + [lims(1) lims(1)], 'Color', 'k');
        end
end
end