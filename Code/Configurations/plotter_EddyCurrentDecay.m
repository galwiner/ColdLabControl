function plotter_EddyCurrentDecay(app,p,r,varargin)
%varargin{1} - plot to fig and not app, if varargin(1)==1
if nargin==4 && varargin{1} == 1 %if a figure is passed and not an app
    %'Position' =[lowerleft,upperright,width,hight]
    ax1 =axes(app,'Position',[0.1 0.15 0.35 0.75]);
    ax2 = axes(app,'Position',[0.58 0.15 0.35 0.75]);
else
%     ax1=uiaxes(app.PlotingAreaPanel,'Position',[15 5 550 360]);
plotingAreaPositision = app.PlotingAreaPanel.Position;
width = plotingAreaPositision(3);
hight = plotingAreaPositision(4);
ax1pos = [10 10 0.47*width-10 0.9*hight];
ax2pos = [(0.5*width+10) 10 0.47*width-10 0.9*hight];
if isempty(app.PlotingAreaPanel.Children)
    ax1 =uiaxes(app.PlotingAreaPanel);
    ax2 = uiaxes(app.PlotingAreaPanel);
else
    ax1 = app.PlotingAreaPanel.Children(1);
    cla(ax1)
    ax2 = app.PlotingAreaPanel.Children(2);
    cla(ax2)
end
set(ax1,'Position',ax1pos);
set(ax2,'Position',ax2pos);
    if isempty(p.loopVals)
        app.validfileLamp.Color='r';
        return
    end
    app.validfileLamp.Color='g';
end
%data proscesing
zeroLess = []; % zeroLess is the data without zero patting
r.truncatedScopeData = []; %a matrix of zeroLess data
r.normalizationFactor = []; %The maximum PMT signal of the depumping flash. We use this to normelize the population transfer
r.transferEffitiency = [];%The maximum PMT signal of the second flash, after the MW pulse, properly normelized
for ii = 1:length(p.loopVals{1})
    for jj = 1:length(p.loopVals{2})
        zeroLess = r.scopeRes{1}(r.scopeRes{1}(:,3,jj,ii)~=0,3,jj,ii); %remove 0's
        if ~isempty(zeroLess)
            r.truncatedScopeData(:,jj,ii) = zeroLess;
        else
            r.truncatedScopeData(:,jj,ii) = nan; %if scope did not trigger, mage value nan
        end
    end
end
midPoint = ceil(length(r.truncatedScopeData(:,1,1))/2); %devide the scope data into the two flashes
r.normalizationFactor = squeeze(max(r.truncatedScopeData(1:midPoint,:,:),[],1));
r.transferEffitiency = (squeeze(max(r.scopeRes{1}(midPoint:end,3,:,:),[],1))-r.LightBg)./(r.normalizationFactor-r.LightBg);
r.detuning  = (p.loopVals{1} - 34.678261)*1000; %detuning from mf=0->mf=0 resonance, in kHz.
    if isvector(r.transferEffitiency)
        [maxVal,maxInd]= max(r.transferEffitiency);
        background = abs(min(r.transferEffitiency));
        amp = maxVal - background;
        [FWHM,upInd,downInd] = findFWHM(r.detuning,r.transferEffitiency,maxInd);
    else
        [maxVal,maxInd]= max(r.transferEffitiency,[],2);
        background = abs(min(r.transferEffitiency,[],2));
        amp = maxVal - background;
        for ii = 1:length(p.loopVals{2})
            [FWHM(ii),upInd(ii),downInd(ii)] = findFWHM(r.detuning,r.transferEffitiency(ii,:),maxInd(ii));
        end
    end
    
    
    initParams = [amp,r.detuning(maxInd)',1./FWHM',background];
    lowerVals = [amp/4,r.detuning(maxInd)'-15,1./(10*FWHM'),background/2];
    upperVals = [amp*4,r.detuning(maxInd)'+15,10./FWHM',background*2];
    freqs = linspace(r.detuning(1),r.detuning(end),1000); %a frequency vector for ploting the fits.
    fits = zeros(length(freqs),length(p.loopVals{2})); %
%loop over hold times, and fit
for ii = 1:length(p.loopVals{2})
    if amp(ii)<0.05
        if ~exist('dontPlotInd','var')
        dontPlotInd = ii;
        else
            dontPlotInd = [dontPlotInd,ii];
        end
        fitCents(ii) = nan;
        continue
    end
    
    if isvector(r.transferEffitiency)
        goodValsInd = ~isnan(r.transferEffitiency);
        [fitobject,gof,~] = fitSinc(r.detuning(goodValsInd),r.transferEffitiency(goodValsInd),initParams,lowerVals,upperVals);
    else
        goodValsInd = ~isnan(r.transferEffitiency(ii,:));
        [fitobject,gof,~] = fitSinc(r.detuning(goodValsInd),r.transferEffitiency(ii,goodValsInd)',initParams(ii,:),lowerVals(ii,:),upperVals(ii,:));
    end
    fits(:,ii) = fitobject(freqs);
    rsquared(ii) = gof.rsquare;
    fitCents(ii) = fitobject.center;
end
plot(ax1,p.loopVals{2}/1e3,abs(fitCents),'-o','LineWidth',2)
xlabel(ax1,'Hold Time [ms]')
ylabel(ax1,'Zeeman shift [kHz]')
title(ax1,'Eddy currents decay');
set(ax1,'FontSize',12);


hold(ax2,'on')
    if length(p.loopVals{2})>1
        for ii=1:length(p.loopVals{2})
            plot(ax2,r.detuning,r.transferEffitiency(ii,:)+(ii-1)*0.1,'o')
            %             legendList{ii} = sprintf('HHY current %0.2f [mA]',p.loopVals{2}(ii)*1e3);
            plot(ax2,freqs,fits(:,ii)+(ii-1)*0.1)
        end
%         legend(legendList);
    else
        plot(ax2,r.detuning,r.transferEffitiency,'o')
        plot(ax2,freqs,fits)
    end
xlabel(ax2,'Detuning [kHz]')
title(ax2,'Transfer efficiency');
set(ax2,'FontSize',12);

end
