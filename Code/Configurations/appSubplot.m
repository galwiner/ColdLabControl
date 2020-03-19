function [ax,position,inset] = appSubplot(appHandle,m,n,l)
%This function is a subplot for app objects.
%LD 09/08/2018

%appHandle is the handle you want to plot on. Important - the handle should
%be for plotting only. If other elements are needed on the figure, use a
%panel.
%m - # of rows; n - # of columns; l - spesific location within grid (could
%be a vector, like [2 4]. l must be <= m*n

%for replacement: nrows = m;
parent = appHandle;
parPos = get(parent,'Position');
normVec = [parPos(3),parPos(4),parPos(3),parPos(4)];
inset = [.02, .018, .04, .01]; % [left bottom right top]
% assert(l<=m*n,'l must be <= to n*m!');
def_pos = get(parent,'DefaultAxesPosition');
row = (m - 1) - fix((l - 1) / n);
col = rem(l - 1, n);
rw = max(row) - min(row) + 1;
cw = max(col) - min(col) + 1;
width = def_pos(3) / (n - inset(1) - inset(3));
height = def_pos(4) / (m - inset(2) - inset(4));
inset = inset .* [width, height, width, height];
outerpos = [def_pos(1) + min(col) * width - inset(1), ...
    def_pos(2) + min(row) * height - inset(2), ...
    width * cw, height * rw];
if min(col) == 0
    inset(1) = def_pos(1);
    outerpos(3) = outerpos(1) + outerpos(3);
    outerpos(1) = 0;
end
if min(row) == 0
    inset(2) = def_pos(2);
    outerpos(4) = outerpos(2) + outerpos(4);
    outerpos(2) = 0;
end
if max(col) == n - 1
    inset(3) = max(0, 1 - def_pos(1) - def_pos(3));
    outerpos(3) = 1 - outerpos(1);
end
if max(row) == m - 1
    inset(4) = max(0, 1 - def_pos(2) - def_pos(4));
    outerpos(4) = 1 - outerpos(2);
end

% compute inner position
position = [outerpos(1 : 2) + inset(1 : 2), ...
    outerpos(3 : 4) - inset(1 : 2) - inset(3 : 4)].*normVec;
inset = inset.*normVec;
ax = uiaxes(parent);
% ax.Units = get(parent, 'DefaultAxesUnits');
% addAxesToGrid(ax, m, n, row, col, position, l);
function addAxesToGrid(ax, nRows, nCols, row, col, position, plotId)
    p = ax.Parent;
    grid = getappdata(p, 'SubplotGrid');
    if isempty(grid)
        grid = gobjects(nRows,nCols);
    end
    
    %when subplot is not in a single grid cell for the current grid,
    %don't add it to the auto-layout
    if any(size(grid) ~= [nRows, nCols]) ... %active grid shape does not match n,m
            || length(row) ~= 1 || length(col) ~= 1 ... %multi-cell subplot
            || round(row) ~= row || round(col) ~= col ... %non-integer cell specified
            || grid(row + 1, col + 1) == ax %axes is already in cell m,n,p
        setappdata(ax,'SubplotGridLocation',{nRows,nCols,plotId})
        setappdata(ax, 'SubplotPosition', position); % normalized
        return
    end
        
    grid(row + 1, col + 1) = ax;

%     % add SubplotListenersManager to p
%     if ~isappdata(p,'SubplotListenersManager')
%         lm =  matlab.graphics.internal.SubplotListenersManager(nRows*nCols);
%         % create an empty filed so that other tests wont complain
%         setappdata(p,'SubplotListeners',[]);
%     else
%         lm=getappdata(p,'SubplotListenersManager');
%     end
%     lm.addToListeners(ax,[]);
%     setappdata(p,'SubplotListenersManager',lm);
    
    % add SubplotDeleteListenersManager to axes
    if ~isappdata(ax,'SubplotDeleteListenersManager')
        dlm =  matlab.graphics.internal.SubplotDeleteListenersManager();
        dlm.addToListeners(ax);
        setappdata(ax,'SubplotDeleteListenersManager',dlm); 
    end
    
    setappdata(ax,'SubplotGridLocation',{nRows,nCols,plotId})
    setappdata(p,  'SubplotGrid', grid)
    setappdata(ax, 'SubplotPosition', position); % normalized
    subplotlayoutInvalid(handle(ax), [], p);
end
end