function allenMapPolyCentered(dorsalMaps, bregma, side, colorFill, scaleBar, hAx)
% allenMapWithLabels(dorsalMaps [, side] [, colorFill] [, scaleBar])
% 
% Produce a dorsal-view Allen atlas map using polygons instead of an image
% (as allenMapWithLabels.m does).
%
% Input "dorsalMaps" should be from allenDorsalMap.mat.
%
% If input "side" is 'Left' or 'l', show labels on the left hemisphere. If
% "side" is 'Right' or 'r', show on the right hemisphere. If side is '', do
% not show labels. Default 'l'.
%
% If colorFill is supplied and <1, each polygon will be filled with
% color. The value of colorFill is the lightness, where 0 is fully
% saturated and 1 is pure white. Default 0.85.
%
% If scaleBar is supplied, a scale bar of this length in mm will be added.
% <=0 or NaN will turn off. Default 1.


%% Parameters

lineWidth = 1;          % Line width for area outlines
outlineColor = [0 0 0]; % Color of whole-brain outline
whiteThresh = 0.75;     % Lightest a color is permitted to be
whiteLabelThresh = 0.4; % How light an area can be and still use a black label (lower gives more black labels)
defaultColorFill = 0.85;
scaleBarPos = [11.5 0]; % XY coordinates of top of scale bar relative to the top of the brain


%% Optional arguments

if ~exist('side', 'var')
  side = 'l';
elseif ~ischar(side) || ~isempty(side) && strcmpi(side(1), 'l')
  side = 'l';
elseif ~isempty(side)
  side = 'r';
end

if ~exist('colorFill', 'var')
  colorFill = defaultColorFill;
end

if ~exist('scaleBar', 'var')
  scaleBar = 1;
end


%% Give short names to info from dorsalMaps

polyMap = dorsalMaps.edgeOutlineSplit;
sides = dorsalMaps.sidesSplit;
labels = dorsalMaps.labelsSplit;

%% Get bregma values
bregmaX = bregma(1);
bregmaY = bregma(2);


%% Choose color map

nAreas = sum(strcmp(sides, 'L'));

if colorFill ~= 1
    cmap = colorcube(nAreas);
    
    % Fix near-whites
    cmapMeans = mean(cmap, 2);
    cmap(cmapMeans > whiteThresh, :) = cmap(cmapMeans > whiteThresh, :) - (1 - whiteThresh);
    
    % Above colormap is for the outlines, produce a lightened map for the fills
    cmapFills = colorFill * ones(size(cmap)) + (1 - colorFill) * cmap;
    
else
    % Use white only if that is asked for
    cmap = zeros(1,nAreas*3);
    cmap = reshape(cmap,[nAreas 3]);
    cmapFills = colorFill * ones(size(cmap)) + (1 - colorFill) * cmap;
end

%% Plot the overall outline
% This is the last entry in the edgeOutline cell array, and doesn't count
% in nAreas because its "sides" value is empty

if nargin < 6
    figure;
    hold on;
    hAx = gca;
end

scale = 1;%dorsalMaps.allenPixelSize / dorsalMaps.desiredPixelSize;
plot(hAx, (polyMap{end}(:, 2) * scale) - bregmaX, (polyMap{end}(:, 1) * scale) - bregmaY, 'color', outlineColor, 'LineWidth', lineWidth);


%% Plot all the areas
    
leftMap = polyMap(strcmp(sides, 'L'));
rightMap = polyMap(strcmp(sides, 'R'));

for a = 1:nAreas
    fill(hAx, (leftMap{a}(:, 2) * scale) - bregmaX, (leftMap{a}(:, 1) * scale) - bregmaY, cmapFills(a, :), 'EdgeColor', cmap(a, :), 'LineWidth', lineWidth);
    fill(hAx, (rightMap{a}(:, 2) * scale) - bregmaX, (rightMap{a}(:, 1) * scale) - bregmaY, cmapFills(a, :), 'EdgeColor', cmap(a, :), 'LineWidth', lineWidth);
end

%% Add the area labels if desired

if ~isempty(side)
  % Grab the labels for the correct side (should actually be the same, but
  % need one side only)
  labs = labels(strcmpi(sides, side));
  
  % Compute the coordinates for the text. This isn't really the right way,
  % because it's the mean of the outline points only and therefore won't
  % necessarily give the true center of mass. It's way easier though and
  % works fine in practice.
  centroids = cellfun(@(p) mean(p, 1), polyMap(strcmpi(sides, side)), 'UniformOutput', 0);
  
  % If the background is light, use black text; if dark, use white text
  for a = 1:length(labs)
    if mean(cmapFills(a, :)) > whiteLabelThresh
      color = [0 0 0];
    else
      color = [1 1 1];
    end

    text(centroids{a}(2), centroids{a}(1), labs{a}, 'color', color, 'Horiz', 'center');
  end
end


%% Add the scale bar

if ~isnan(scaleBar) && scaleBar > 0
  scaleBarPos = scaleBarPos * 1000 / dorsalMaps.desiredPixelSize;
  plot(hAx, scaleBarPos(1) + [0 0] - bregmaX, scaleBarPos(2) + [0 scaleBar] * 1000 / dorsalMaps.desiredPixelSize - bregmaY, 'k-', 'LineWidth', 3);
end


%% Clean up plot properties

% Make it square, full size, and kill the axes
% axis equal tight off;

% Put it upright (outlines are extracted from an image so coordinates use
% the image convention of (0, 0) being in the top left)
set(hAx, 'YDir', 'reverse');

% Set the figure background to white, since we've turned off the axes
set(hAx, 'color', [1 1 1]);
