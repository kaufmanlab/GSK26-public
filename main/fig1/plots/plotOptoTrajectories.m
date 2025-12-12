function plotOptoTrajectories(kinematics, plotParams)
% Plot trajectories from an opto dataset

% Make figure
fig;
hA = gca;
axis off
hold on;
hA.View = [-22,4];
axis equal

% Plot only right trials, opto in blue and normal in gray
optocount = 0;
normalcount = 0;
target = 2; % Rights only
for tr = 1:length(kinematics)
    if kinematics(tr).LR == target
        if kinematics(tr).optoTrial == 1
            optocount = optocount + 1;
            bins = 1:length(kinematics(tr).tPts);
            % Plot traces and locations at cue
            plotParams.traceColors = [0, 0.9, 0.9];
            plotParams.traceAlpha = 0.4;
            plotParams.traceLineWidth = 1.5;
            drawTrace(hA, permute(mean(kinematics(tr).posXYZ(bins,:,2:3),3), [1, 4, 2, 3]), plotParams);
            plot3(mean(kinematics(tr).posXYZ(1,1,2:3),3), mean(kinematics(tr).posXYZ(1,2,2:3),3), mean(kinematics(tr).posXYZ(1,3,2:3),3), '.', 'Color', plotParams.traceColors, 'MarkerSize', 10);
        end
    end
end
nControlTrials = 60;
for tr = 1:length(kinematics)
    if kinematics(tr).LR == target
        if kinematics(tr).optoTrial == 0 && tr < nControlTrials
            normalcount = normalcount + 1;
            bins = 1:length(kinematics(tr).tPts);
            plotParams.traceColors = [0.25, 0.25, 0.25];
            plotParams.traceAlpha = 0.6;
            plotParams.traceLineWidth = 0.25;
            drawTrace(hA, permute(mean(kinematics(tr).posXYZ(bins,:,2:3),3), [1, 4, 2, 3]), plotParams);
            plot3(mean(kinematics(tr).posXYZ(1,1,2:3),3), mean(kinematics(tr).posXYZ(1,2,2:3),3), mean(kinematics(tr).posXYZ(1,3,2:3),3), '.', 'Color', plotParams.traceColors, 'MarkerSize', 10);
        end
    end
end

% Clean up axes
coordAxes(hA, [8, 90, -20], 3, 12, [-1,-1,1])

end