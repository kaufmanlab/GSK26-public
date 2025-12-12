function plotSkeleton(posXYZ, plotParams, view)

% Configure plot
fig;
hA = gca;
hA.View = view;
axis(hA, 'equal');
axis off
hA.ZLim = [-18, 17];
hA.XLim = [-5, 65];
hA.YLim = [-25, 20];

% Loop over time points, adding offsets
for t = 1:size(posXYZ,1)
    pos = posXYZ(t,:,:);
    pos = pos - pos(:,:,15) + repmat([t * 10 0 0],1,1,25);
    drawSkeleton(hA, pos, plotParams);
    drawMarkers(hA, pos, plotParams);
end

end