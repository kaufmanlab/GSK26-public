function reconPosePlot(output, M, trialIdx, frames, offsets)
% Plot the skeletons for original and reconstructed data

% Params
trialNumber = output.outcomes(trialIdx).trialNumber;
if output.outcomes(trialIdx).LR == 1
    color = [0,0,1];
else
    color = [1,0,0];
end
M.plotParams.linkLineWidth = 0.5;
M.plotParams.markers2Plot = 1:15;
M.plotParams.skeleton2Plot = M.skeleton(1:17,:);

linkColorsRecon = colormapHSV(repmat(color, length(M.plotParams.skeleton2Plot), 1), [], [], linspace(1, 0.6, length(M.plotParams.skeleton2Plot)));
markerColorsRecon = colormapHSV(repmat(color, length(M.plotParams.markers2Plot), 1), [], [], linspace(1, 0.6, length(M.plotParams.markers2Plot)));
linkColorsOrig = colormapHSV(repmat([0.5,0.5,0.5], length(M.plotParams.skeleton2Plot), 1), [], [], linspace(1, 0.5, length(M.plotParams.skeleton2Plot)));
markerColorsOrig = colormapHSV(repmat([0.5,0.5,0.5], length(M.plotParams.markers2Plot), 1), [], [], linspace(1, 0.5, length(M.plotParams.markers2Plot)));

M.plotParams.linkColors = cat(3,linkColorsOrig, linkColorsRecon);
M.plotParams.markerColors = cat(3,markerColorsOrig, markerColorsRecon);

% Figure
fig;
hA = gca;
hA.View = [-5,5];
hold on;
axis off
axis equal
title(sprintf('trial %i', trialNumber), 'FontSize', 8, 'FontWeight', 'normal');

% Loop over frames
count = 1;
for fr = frames
    offset = offsets(count,:);
    OG = output.outcomes(trialIdx).posXYZ(fr,:,:);
    OG = OG - OG(:,:,15) + repmat(offset,1,1,25);
    recon = output.outcomes(trialIdx).posXYZRecon(fr,:,:);
    recon = recon - recon(:,:,15) + repmat(offset,1,1,25);
    posXYZt = cat(1, OG, recon);
    drawMarkers(hA, posXYZt, M.plotParams);
    drawSkeleton(hA, posXYZt, M.plotParams);
    count = count + 1;
end

coordAxes(hA, [mean(offsets(end-1:end,1)),-5,-20], 4, 7, [-1, -1, 1])
end