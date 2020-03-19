function fitCents=plotter_BiasCancelation(app,p,r,varargin)
%varargin{1} - plot to fig and not app, if varargin(1)==1
if nargin==4 && varargin{1} == 1
    ax1 = app;
else
    ax1=uiaxes(app.PlotingAreaPanel,'Position',[15 5 550 360]);
    if isempty(p.loopVals)
        app.validfileLamp.Color='r';
        return
    end
    app.validfileLamp.Color='g';
end
freqs = linspace(r.detuning(1),r.detuning(end),200);
fits = zeros(length(freqs),length(p.loopVals{2}));
%     for ii = 1:length(p.loopVals{2})
%         [fitobject,gof,output] = fitSinc(r.detuning,r.transferEffitiency(ii,:)',initParams,lower,upper);
%         fits(:,ii) = fitobject(freqs);
%         rsquared(ii) = gof.rsquare;
%         fitCents(ii) = fitobject.center;
%     end
%         plot(p.loopVals{2}/1e3,abs(fitCents),'-o','LineWidth',2)
%         xlabel('Hold Time [ms]')
%         ylabel('Zeeman shift [kHz]')
%         set(gca,'FontSize',16);
%         title('Eddy currents decay');

%
hold(ax1,'on')
if length(p.loopVals{2})>1
    for ii=1:length(p.loopVals{2})
        plot(ax1,r.detuning,r.transferEffitiency(ii,:)+(ii-1)*0.1,'-o','LineWidth',2)
        %             legendList{ii} = sprintf('HHY current %0.2f [mA]',p.loopVals{2}(ii)*1e3);
%         plot(ax1,freqs,fits(:,ii)+(ii-1)*0.1)
    end
    %         legend(legendList);
else
    plot(r.detuning,r.transferEffitiency,'-o','LineWidth',2)
end


end
