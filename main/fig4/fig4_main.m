%% Figure 4 main
YOURDATAPATH = '';

%% PANEL A:
% FOVs on Allen CCF

% FOV information
locsM1 = [[-1.823, -1.193]; ...
    [-1.754, -0.153]; ...
    [-1.592, -0.625]; ...
    [-1.444, -0.561]; ...
    [-1.587, -0.699]];
locsS1 = [[-2.584, 0.191]; ...
    [-2.578, -0.274]; ...
    [-2.801, -0.079]; ...
    [-2.259, -0.074]; ...
    [-2.758, 0.283]];
rotations = -[[15.75, 15.75];[14.65,12.25];[15.25,14];[13.23, 11.11];[19,19]];

% Plot
plotFOVsAllenCCF(locsM1, locsS1, rotations)

%% Get data for panel B:
% Loads the ZETA p values for all datasets, this will take a few minutes
mouseInfoM1 = {{'cfa17', '200825'}, {'cfa19', '200820'}, {'cfa20', '201114'}, {'cfa22', '220605'}, {'cfa24', '220727'}};
modScoresM1 = loadCombinedModscores(mouseInfoM1, YOURDATAPATH, 'waterTime');

mouseInfoS1 = {{'cfa17', '200827'}, {'cfa19', '200826'}, {'cfa20', '201118'}, {'cfa22', '220611'}, {'cfa24', '220724'}};
modScoresS1 = loadCombinedModscores(mouseInfoS1, YOURDATAPATH, 'waterTime');

%% Panel B:
% ZETA p value scatter plots
plotZETAScores(modScoresM1, 0.025)
plotZETAScores(modScoresS1, 0.025)

%% Get data for panel C:
mouse = 'cfa17';
session = '200825';
[R, M, ~] = loadData(mouse, session, 'R', 'DLC3', YOURDATAPATH);

%% Panel C:
% PETHs from mouse 1 M1
M1_cells = [[6, 54]; [11, 67]; [35, 132]];
[R, M] = timeClus(R, M, 'movementTime');
for roi = M1_cells(1,:)
    rasterPETH(R, M, roi, 'waterTime', 100, 700, 'movementTimeClus', 'movementTime')
end
for roi = M1_cells(2,:)
    rasterPETH(R, M, roi, 'liftTimeDLC', 100, 700, 'movementTimeClus', 'movementTime')
end
for roi = M1_cells(3,:)
    rasterPETH(R, M, roi, 'grabTimeC', 400, 400, 'movementTimeClus', 'movementTime')
end

%% Get data for panel D:
mouse = 'cfa17';
session = '200827';
[R, M, ~] = loadData(mouse, session, 'R', 'DLC3', YOURDATAPATH);

%% Panel D:
% PETHs from mouse 1 S1
S1_cells = [[123, 149]; [112, 116]; [48, 187]];
[R, M] = timeClus(R, M, 'movementTime');
for roi = S1_cells(1,:)
    rasterPETH(R, M, roi, 'waterTime', 100, 700, 'movementTimeClus', 'movementTime')
end
for roi = S1_cells(2,:)
    rasterPETH(R, M, roi, 'liftTimeDLC', 100, 700, 'movementTimeClus', 'movementTime')
end
for roi = S1_cells(3,:)
    rasterPETH(R, M, roi, 'grabTimeC', 400, 400, 'movementTimeClus', 'movementTime')
end