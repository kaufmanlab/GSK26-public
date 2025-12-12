function arrow3D(pos, deltaValues, colorCode, stemRatio)
% Plots a simple 3D arrow via a cylinder and a cone
X = pos(1);
Y = pos(2);
Z = pos(3);

% Get polar coordinates
[sphi, stheta, srho] = cart2sph(deltaValues(1), deltaValues(2), deltaValues(3));

% Create stem as cylinder
cylinderRadius = 0.05*srho;
cylinderLength = srho*stemRatio;
[CX,CY,CZ] = cylinder(cylinderRadius);
CZ = CZ.*cylinderLength;

% Rotate cylinder
[row, col] = size(CX);
newEll = rotatePoints([0 0 -1], [CX(:), CY(:), CZ(:)]);
CX = reshape(newEll(:,1), row, col);
CY = reshape(newEll(:,2), row, col);
CZ = reshape(newEll(:,3), row, col);
[row, col] = size(CX);
newEll = rotatePoints(deltaValues, [CX(:), CY(:), CZ(:)]);
stemX = reshape(newEll(:,1), row, col);
stemY = reshape(newEll(:,2), row, col);
stemZ = reshape(newEll(:,3), row, col);

% Translate cylinder
stemX = stemX + X;
stemY = stemY + Y;
stemZ = stemZ + Z;

% Create head as cone
coneLength = srho*(1-stemRatio);
coneRadius = cylinderRadius*1.5;
incr = 4;
coneincr = coneRadius/incr;
[coneX, coneY, coneZ] = cylinder(cylinderRadius*2:-coneincr:0);
coneZ = coneZ.*coneLength;

% Rotate cone
[row, col] = size(coneX);
newEll = rotatePoints([0 0 -1], [coneX(:), coneY(:), coneZ(:)]);
coneX = reshape(newEll(:,1), row, col);
coneY = reshape(newEll(:,2), row, col);
coneZ = reshape(newEll(:,3), row, col);

newEll = rotatePoints(deltaValues, [coneX(:), coneY(:), coneZ(:)]);
headX = reshape(newEll(:,1), row, col);
headY = reshape(newEll(:,2), row, col);
headZ = reshape(newEll(:,3), row, col);

% Translate cone
V = [0, 0, srho*stemRatio];
Vp = rotatePoints([0 0 -1], V);
Vp = rotatePoints(deltaValues, Vp);
headX = headX + Vp(1) + X;
headY = headY + Vp(2) + Y;
headZ = headZ + Vp(3) + Z;

% Plot
surf(stemX, stemY, stemZ, 'FaceColor', colorCode, 'EdgeColor', 'none');
surf(headX, headY, headZ, 'FaceColor', colorCode, 'EdgeColor', 'none');

end


