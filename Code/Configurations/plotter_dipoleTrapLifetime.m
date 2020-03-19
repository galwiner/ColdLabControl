function plotter_dipoleTrapLifetime(app,p,r,varargin)
%varargin{1} - plot to fig and not app, if varargin(1)==1
if nargin==4 && varargin{1} == 1 %if a figure is passed and not an app
    %'Position' =[lowerleft,upperright,width,hight]
    ax1 =axes(app,'Position',[0.1 0.15 0.85 0.75]);
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
meanAtomNum = mean(squeeze(r.atomNum{1}),2);

[fitobj,gof,output] = fitExpDecay(p.loopVals{1}*1e-6,meanAtomNum,[4e6,0.1,1e4]);
conf = confint(fitobj);
errorBars = std(squeeze(r.atomNum{1}),[],2);
errorbar(ax1,p.loopVals{1}*1e-6,meanAtomNum,errorBars,'o')
hold(ax1,'on')
plot(p.loopVals{1}*1e-6,fitobj(p.loopVals{1}*1e-6))
titlestr = sprintf('Dipole trap decay time = %0.2f (%0.2f %0.2f) [s]',fitobj.tau,conf(1,2),conf(2,2));
title(ax1,titlestr)
xlabel(ax1,'time [sec]');
ylabel(ax1,'Atoms in the trap');
set(ax1,'FontSize',12)
end
