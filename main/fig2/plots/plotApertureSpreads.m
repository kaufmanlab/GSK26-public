function plotApertureSpreads(kinematics, maxpeaks)
% Plots the time series of mean aperture with the 25th and 75th percentile
% spreads across trials

if nargin < 2
    maxpeaks = 3;
end

% Aperture trace windows, with lift locking and speed alignment
nbefore = 10;
nafter = 10;
kinematics = alignAperture(kinematics, nbefore, nafter);

% Figure
fig;
hold on;
axis off

xoffset = 3;
ymult = 7;

count = 0;
mice = unique({kinematics.animalID});
for mouse = mice
    
    yoffset = ymult * count;
    
    trials_ = find(cellfun(@(x) strcmp(x, mouse), {kinematics.animalID}));
    kinematics_ = kinematics(trials_);
    
    % Rights
    trialsR = find([kinematics_.LR] == 2 & [kinematics_.aligned] == 1 & [kinematics_.nPeaks] <= maxpeaks);
    aperture = cat(1,kinematics_(trialsR).alignedaperture);
    apmeR = median(aperture)';
    apQ1R = prctile(aperture, 25)';
    apQ3R = prctile(aperture, 75)';
    
    % Left
    trialsL = find([kinematics_.LR] == 1 & [kinematics_.aligned] == 1 & [kinematics_.nPeaks] <= maxpeaks);
    aperture = cat(1,kinematics_(trialsL).alignedaperture);
    apmeL = median(aperture)';
    apQ1L = prctile(aperture, 25)';
    apQ3L = prctile(aperture, 75)';
    
    % Plot
    % Lefts
    alignedbins = -nbefore:1:nafter;
    binsL = 1:length(alignedbins);
    fill([binsL';flipud(binsL')], [apQ1L; flipud(apQ3L)] + yoffset, colormapHSV([0,0,1], [], 0.2, []), 'LineStyle', 'none', 'FaceAlpha', 0.4)
    plot(binsL, apmeL + yoffset, 'Color', [0,0,1,1], 'LineWidth', 0.75)
    
    % Rights
    binsR = (1:length(alignedbins)) + length(alignedbins) + xoffset;
    fill([binsR';flipud(binsR')], [apQ1R; flipud(apQ3R)] + yoffset, colormapHSV([1,0,0], [], 0.2, []), 'LineStyle', 'none', 'FaceAlpha', 0.4)
    plot(binsR, apmeR + yoffset, 'Color', [1,0,0,1], 'LineWidth', 0.75)
    
    if count == 0
        minY = min([apQ1L; apQ1R] + yoffset);
    end
    
    if count == length(mice) - 1
        maxY = max([apQ3L; apQ3R] + yoffset);
    end
    
    % Show # of trials
    text(binsL(alignedbins == -5), apQ1L(alignedbins == -5) + yoffset - 1, sprintf('%i trials', length(trialsL)), 'HorizontalAlignment', 'center');
    % Show # of trials
    text(binsR(alignedbins == -5), apQ1R(alignedbins == -5) + yoffset - 1, sprintf('%i trials', length(trialsR)), 'HorizontalAlignment', 'center');
    
    count = count + 1;
    
end

xlim([binsL(1), binsR(end)])
ylim([minY - 2, maxY])

% Left
clear haxParams
haxParams.axisOrientation = 'h';
haxParams.tickLocations = [binsL(1), binsL(alignedbins == 0), binsL(end)];
haxParams.tickLabels = {num2str(-nbefore*10), 'max paw Z vel', num2str(nafter*10)};
haxParams.tickLabelLocations = [binsL(1), binsL(alignedbins == 0), binsL(end)];
haxParams.axisOffset = minY - 1;
haxParams.fontSize = 8;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);
line([binsL(alignedbins == 0), binsL(alignedbins == 0)], [minY - 1, maxY], 'Color', [0,0,0, 0.5], 'LineWidth', 1, 'LineStyle', '--');

% Right
clear haxParams
haxParams.axisOrientation = 'h';
haxParams.tickLocations = [binsR(1), binsR(alignedbins == 0), binsR(end)];
haxParams.tickLabels = {num2str(-nbefore*10), 'max paw Z vel', num2str(nafter*10)};
haxParams.tickLabelLocations = [binsR(1), binsR(alignedbins == 0), binsR(end)];
haxParams.axisOffset = minY - 1;
haxParams.fontSize = 8;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);
line([binsR(alignedbins == 0), binsR(alignedbins == 0)], [minY - 1, maxY], 'Color', [0,0,0, 0.5], 'LineWidth', 1, 'LineStyle', '--');

end

function kinematics = alignAperture(kinematics, nbefore, nafter)
% Small function to align aperture to maximum Z speed bin
% Works on already lift-locked data

[kinematics.aligned] = deal(0);
for trial = 1:length(kinematics)
    bins = (kinematics(trial).maxZVelBin - nbefore):(kinematics(trial).maxZVelBin + nafter);
    if all(bins > 0) && all(bins < length(kinematics(trial).tPts))
        kinematics(trial).alignedaperture = kinematics(trial).aperture(bins);
        kinematics(trial).alignedaperturebins = bins;
        kinematics(trial).aligned = 1;
    else
        kinematics(trial).aligned = 0;
    end
end
end