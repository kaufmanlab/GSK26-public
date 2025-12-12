function colormap = colormapHSV(colormap, hueMultiplier, satMultiplier, valMultiplier)
if ~isempty(hueMultiplier)
    colormap = colormapHue(colormap, hueMultiplier);
end

if ~isempty(satMultiplier)
    colormap = colormapSat(colormap, satMultiplier);
end

if ~isempty(valMultiplier)
    colormap = colormapVal(colormap, valMultiplier);
end
end

function cmapHue = colormapHue(colormap, hueMultiplier)
if length(hueMultiplier) == 1
    hueMultiplier = hueMultiplier * ones(size(colormap,1),1);
end
if ~iscolumn(hueMultiplier)
    hueMultiplier = hueMultiplier';
end
cmapHue = rgb2hsv(colormap);
for c = 1:size(cmapHue,1)
    if cmapHue(c,1) == 0
        cmapHue(c,1) = cmapHue(c,1) + 1 * min(hueMultiplier(c),1);
    else
        cmapHue(c,1) = cmapHue(c,1) * min(hueMultiplier(c),1);
    end
end
cmapHue = hsv2rgb(cmapHue);
end

function cmapSat = colormapSat(colormap, satMultiplier)
if length(satMultiplier) == 1
    satMultiplier = satMultiplier * ones(size(colormap,1),1);
end
if ~iscolumn(satMultiplier)
    satMultiplier = satMultiplier';
end
cmapSat = rgb2hsv(colormap);
cmapSat(:,2) = cmapSat(:,2) .* min(satMultiplier,1);
cmapSat = hsv2rgb(cmapSat);
end

function cmapVal = colormapVal(colormap, valMultiplier)
if length(valMultiplier) == 1
    valMultiplier = valMultiplier * ones(size(colormap,1),1);
end
if ~iscolumn(valMultiplier)
    valMultiplier = valMultiplier';
end
cmapVal = rgb2hsv(colormap);
cmapVal(:,3) = cmapVal(:,3) .* min(valMultiplier,1);
cmapVal = hsv2rgb(cmapVal);
end