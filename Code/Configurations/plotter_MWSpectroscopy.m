function plotter_MWSpectroscopy(app,p,r)
    ax1=uiaxes(app.PlotingAreaPanel);
    try
    app.validfileLamp.Color='g';
    bgres = mean(r.bgscope(:,3));
    initParams = [335,0,0.3,0.06,1500];
    lower = [330,-pi/3,0.09,0.02,1000];
    upper = [340,pi/3,0.7,0.07,5000];
    transferEfficiency = squeeze(max(r.scopeRes{1}(:,3,:),[],1))-bgres;
    [fitobject,gof,output] = fitRabiOscilations(p.loopVals{1},transferEfficiency,initParams,lower,upper);
    time = linspace(p.loopVals{1}(1),p.loopVals{1}(end),300);
    
    plot(ax1,p.loopVals{1},transferEfficiency,'LineWidth',2)
    hold on
    plot(ax1,time,fitobject(time))
    title(ax1,'MW Rabi oscillations');
    xlabel(ax1,'MW Pulse Time [\mus]')
    ylabel(ax1,'Normalized Max PMT signal');
%     set(,'FontSize',16)
    xlim([min(p.loopVals{1}) max(p.loopVals{1})]);
    catch err
        if strcmpi('MATLAB:badsubscript',err.identifier)
            app.validfileLamp.Color='r';
        end
    end
    
%     disp(fitobject)
end
