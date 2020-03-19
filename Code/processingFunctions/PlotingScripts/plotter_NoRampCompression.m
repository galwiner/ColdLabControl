function plotter_NoRampCompression(app,p,r,varargin)
%varargin{1} - plot to fig and not app, if varargin(1)==1
if nargin==4 && varargin{1} == 1 %if a figure is passed and not an app
    %'Position' =[lowerleft,upperright,width,hight]
    ax1 =axes(app,'Position',[0.15 0.15 0.7 0.75]);
else
%     ax1=uiaxes(app.PlotingAreaPanel,'Position',[15 5 550 360]);
plotingAreaPositision = app.PlotingAreaPanel.Position;
width = plotingAreaPositision(3);
hight = plotingAreaPositision(4);
ax1pos = [10 10 0.9*width-10 0.9*hight];
if isempty(app.PlotingAreaPanel.Children)
    ax1 =uiaxes(app.PlotingAreaPanel);
else
    ax1 = app.PlotingAreaPanel.Children(1);
    cla(ax1)
end
set(ax1,'Position',ax1pos);
    if isempty(p.loopVals)
        app.validfileLamp.Color='r';
        return
    end
    app.validfileLamp.Color='g';
end
if ~isempty(p.loopVals)
    yyaxis(ax1,'left')
    plot(ax1,p.loopVals{1},squeeze(r.atomDensity{1}),'LineWidth',2)
    ylabel(ax1,'Density [cm^-3]')
    yyaxis(ax1,'right')
    plot(ax1,p.loopVals{1},squeeze(r.fitParams{1}(5,:)),'LineWidth',2)
    hold(ax1,'on');
    plot(ax1,p.loopVals{1},squeeze(r.fitParams{1}(6,:)),'LineWidth',2)
    title(ax1,'Density and dimentions')
    ylabel(ax1,'Dimentions [m]')
    xlabel(ax1,p.loopVars{1})
    set(ax1,'FontSize',16)
    hold(ax1,'off');
end
end
