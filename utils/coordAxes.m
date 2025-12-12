function coordAxes(ax, origin, scale, fontSize, flips, letters)

% x0 = 10;
% y0 = 90;
% z0 = -10;

if nargin < 6
    letters = {'X', 'Y', 'Z'};
end

x0 = origin(1);
y0 = origin(2);
z0 = origin(3);

% Make coord axes
Tmat = [[1, 0, 0, x0];[ 0, 1, 0, y0]; [0, 0 ,1, z0]; [0,0,0,1]];
xbar = [[0,0,0,1];[flips(1)*scale,0,0,1]];
ybar = [[0,0,0,1];[0,flips(2)*scale,0,1]];
zbar = [[0,0,0,1];[0,0,flips(3)*scale,1]];
xbar = Tmat*xbar';
ybar = Tmat*ybar';
zbar = Tmat*zbar';

line(ax, xbar(1,:), xbar(2,:), xbar(3,:), 'Color', 'k', 'LineWidth', 1)
line(ax,ybar(1,:), ybar(2,:), ybar(3,:), 'Color', 'k', 'LineWidth', 1)
line(ax, zbar(1,:), zbar(2,:), zbar(3,:), 'Color', 'k', 'LineWidth', 1)

% quiver3(xbar(1,1), xbar(2,1), xbar(3,1), xbar(1,2), xbar(2,2), xbar(3,2), 'Color', 'k', 'LineWidth', 2)
% quiver3(ybar(1,1), ybar(2,1), ybar(3,1), ybar(1,2), ybar(2,2), ybar(3,2), 'Color', 'k', 'LineWidth', 2)
% quiver3(zbar(1,1), zbar(2,1), zbar(3,1), zbar(1,2), zbar(2,2), zbar(3,2), 'Color', 'k', 'LineWidth', 2)

if ~isempty(fontSize)
    xbar = xbar - 1*scale;
    ybar = ybar + 0.5*scale;
    zbar = zbar + 0.5*scale;
    text(ax, xbar(1,2), xbar(2,2), xbar(3,2), letters{1}, 'FontSize', fontSize, 'FontWeight', 'bold')
    text(ax, ybar(1,2), ybar(2,2), ybar(3,2), letters{2}, 'FontSize', fontSize, 'FontWeight', 'bold')
    text(ax, zbar(1,2), zbar(2,2), zbar(3,2), letters{3}, 'FontSize', fontSize, 'FontWeight', 'bold')
end
end