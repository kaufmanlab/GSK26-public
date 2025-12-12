function plotTrajectoryApertureEvents(kinematics)
% Plots centroid trajectories with annotated aperture events

% Figure
fig;
hA = gca;
axis off
hold on;
hA.View = [-12,8];
axis(hA, 'equal');

% Params
tracecol = [0.5,0.5,0.5, 0.5];
liftCol = [130, 235, 118]/255;
collectCol = [72, 188, 255]/255;
extendCol = [230, 40, 151]/255;

% Loop over trials
zoffset = -15;
for tr = 1:length(kinematics)
    
    cenPos = kinematics(tr).CposXYZ;
    if kinematics(tr).LR == 1
        cenPos(:,3) = cenPos(:,3) + zoffset;
    end
    
    % Plot traces for valid trials
    if ~isnan(kinematics(tr).collectBin) && ~isnan(kinematics(tr).extendBin) && kinematics(tr).nPeaks == 1
        lift = find(kinematics(tr).tPts == 0);
        collect = kinematics(tr).collectBin;
        extend = kinematics(tr).extendBin;
        
        % Trace lift:collect
        plot3(cenPos(lift:collect, 1), cenPos(lift:collect, 2), cenPos(lift:collect, 3), 'Color', tracecol, 'LineWidth', 0.25, 'LineStyle', '-');
        
        % Trace collect:extend
        plot3(cenPos(collect:extend, 1), cenPos(collect:extend, 2), cenPos(collect:extend, 3), 'Color', tracecol, 'LineWidth', 0.25, 'LineStyle', '-');
        
        % Lift
        scatter3(cenPos(lift, 1), cenPos(lift, 2), cenPos(lift, 3), 'Marker', '.', 'SizeData', 150, 'CData', liftCol);
        
        % Collect
        scatter3(cenPos(collect, 1), cenPos(collect, 2), cenPos(collect, 3), 'Marker', '.', 'SizeData', 150, 'CData', collectCol);
        
        % Extend
        scatter3(cenPos(extend, 1), cenPos(extend, 2), cenPos(extend, 3), 'Marker', '.', 'SizeData', 150, 'CData', extendCol);
    end
end

coordAxes(hA, [2.5,90,-20], 2, 12, [-1,-1,1])

end