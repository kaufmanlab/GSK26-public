function plotFOVsAllenCCF(locsM1, locsS1, rotations)

% Load data and make plot
load('allenDorsalMap.mat');
bregmaRef = [228.5 205] * dorsalMaps.allenPixelSize / dorsalMaps.desiredPixelSize;
onemm = 1000 / dorsalMaps.desiredPixelSize;
allenMapPolyCentered(dorsalMaps, bregmaRef, '', 1);
plot(0, 0, 'k+', 'MarkerSize', 10, 'LineWidth', 3);

% Params
colors = [[193, 39, 45];[246, 148, 30];[35, 182, 115];[47, 46, 146];[102, 41, 145]]/255;
sizes = repmat([0.81 1], 5, 1);

% Loop over mice
for mouse = 1:5
    
    width = sizes(mouse, 1) * onemm;
    height = sizes(mouse, 2) * onemm;
    
    rx = [-width/2, width/2, width/2, -width/2, -width/2];
    ry = [-height/2, -height/2, height/2, height/2, -height/2];
    
    % M1
    rotm = [[cosd(rotations(mouse, 1)), -sind(rotations(mouse, 1))]; [sind(rotations(mouse, 1)) cosd(rotations(mouse, 1))]];
    rec = rotm*[rx;ry];
    cenx = locsM1(mouse, 1) * onemm;
    ceny = locsM1(mouse, 2) * onemm;
    plot(rec(1,:) + cenx, rec(2,:) + ceny, 'LineWidth', 1, 'Color', colors(mouse,:));
    
    % S1
    rotm = [[cosd(rotations(mouse, 2)), -sind(rotations(mouse, 2))]; [sind(rotations(mouse, 2)) cosd(rotations(mouse, 2))]];
    rec = rotm*[rx;ry];
    cenx = locsS1(mouse, 1) * onemm;
    ceny = locsS1(mouse, 2) * onemm;
    plot(rec(1,:) + cenx, rec(2,:) + ceny, 'LineWidth', 1, 'Color', colors(mouse,:));
    
end

% Set axis
axis equal
box on
xlim([-onemm * 4 0])
ylim([-115.9950   81.3455])
ax = gca;
set(gca, 'XTick', [-3*onemm -2*onemm -onemm]);
set(gca, 'YTick', [-2*onemm -onemm 0 onemm]);
set(gca, 'TickDir', 'out')
set(gca, 'XTickLabels', [-3 -2 -1]);
set(gca, 'YTickLabels', [2 1 0 -1]);
end