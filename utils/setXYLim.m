function setXYLim(ax, setX, setY, spacers)

% Makes the axis limits for X and Y fit the data plotted

if nargin < 4
    spacers = [0, 0, 0, 0]; % No space between axis and data
end

% Allocate for XY data
locs = [];
for ob = ax.Children'
    % Switch on what kinds of objects we could get
    if isprop(ob, 'Position')
        locs = [locs; ob.Position(1:2)];
    elseif isprop(ob, 'XData')
        if isprop(ob, 'Faces')
            locs = [locs; [ob.XData, ob.YData]];
        elseif isprop(ob, 'UData')
            locs = [locs; [ob.XData', ob.YData']; [ob.UData', ob.VData']];
        else
            locs = [locs; [ob.XData', ob.YData']];
        end
    else
        locs = [locs; [NaN, NaN]];
    end
end

% Set lims
if setX
    xlims = [nanmin(locs(:,1)), nanmax(locs(:,1))] + spacers(1:2);
    set(ax, 'XLim', xlims);
end
if setY
    ylims = [nanmin(locs(:,2)), nanmax(locs(:,2))] + spacers(3:4);
    set(ax, 'YLim', ylims);
end

end