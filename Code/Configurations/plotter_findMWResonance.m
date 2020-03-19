function plotter_findMWResonance(app,p,r,varargin)
warning('off');
%varargin{1} - plot to fig and not app, if varargin(1)==1
if nargin==5
    fitFlag=varargin{2};
else
    fitFlag=1;
end

if nargin>3 && varargin{1} == 1 %if a figure is passed and not an app
    %'Position' =[lowerleft,upperright,width,hight]
    ax1 =axes(app,'Position',[0.1 0.15 0.35 0.75]);
    ax2 = axes(app,'Position',[0.58 0.15 0.35 0.75]);
    if isempty(p.loopVals) %if nothing is scaned, do nothing
        return
    end
else
    plotingAreaPositision = app.PlotingAreaPanel.Position; %get position of ploting area, %'Position' =[lowerleft,upperright,width,hight]
    width = plotingAreaPositision(3);
    hight = plotingAreaPositision(4);
    ax1pos = [10 10 0.47*width-10 0.9*hight];
    ax2pos = [(0.5*width+10) 10 0.47*width-10 0.9*hight];
    % check if axes was assigned before
    if isempty(app.PlotingAreaPanel.Children)
        ax1 =uiaxes(app.PlotingAreaPanel);
        ax2 = uiaxes(app.PlotingAreaPanel);
    else %if yes, assing the axes to the previusly assign ones, and clear them
        ax1 = app.PlotingAreaPanel.Children(1);
        cla(ax1)
        ax2 = app.PlotingAreaPanel.Children(2);
        cla(ax2)
    end
    %se position of axes
    set(ax1,'Position',ax1pos);
    set(ax2,'Position',ax2pos);
    
    if isempty(p.loopVals) %if nothing is scaned, do nothing
        app.validfileLamp.Color='r';
        return
    end
    app.validfileLamp.Color='g';
end
try
    zeroLess = [];
%     r.truncatedScopeData = [];

    midPoint = [];
    r.normalizationFactor = [];
    r.transferEffitiency = [];
    r.detuning = [];

%     for ii = 1:length(p.loopVals{1})
%         for jj = 1:length(p.loopVals{2})
%             zeroLess = r.scopeRes{1}(r.scopeRes{1}(:,2,jj,ii)~=0,2,jj,ii);
%             if ~isempty(zeroLess)
%                 r.truncatedScopeData(:,jj,ii) = zeroLess;
%             else
%                 r.truncatedScopeData(:,jj,ii) = nan;
%             end
%         end
%     end
    
    midPoint = ceil(size(r.scopeRes{1},1)/2);
    r.normalizationFactor = squeeze(mean(max(r.scopeRes{1}(1:midPoint,2,:,:,:),[],1),5));
    r.transferEffitiency = (squeeze(mean(max(r.scopeRes{1}(midPoint:end,2,:,:,:),[],1),5))-r.LightBg)./(r.normalizationFactor-r.LightBg);
    r.transferEffitiency(r.transferEffitiency==1) = nan;
    if min(r.transferEffitiency)<-0.05
        if nargin == 3 || varargin{1} ~= 1
            app.validfileLamp.Color='r';
        end
        return
    end
    r.detuning  = (p.loopVals{1} - 34.678261)*1000;
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
    %loop over currents, and fit so sincs
    for ii = 1:length(p.loopVals{2})
        if isvector(r.transferEffitiency)
            nanInd = find(isnan(r.transferEffitiency)==1);
            if ~isempty(nanInd)
                r.transferEffitiency(nanInd) = [];
                r.detuning(nanInd) = [];
            end
            [fitobject,gof,output] = fitSinc(r.detuning,r.transferEffitiency,initParams(ii,:),lowerVals(ii,:),upperVals(ii,:));
        else
            idxValid = ~isnan(r.transferEffitiency(ii,:));
            if fitFlag
            [fitobject,gof,output] = fitSinc(r.detuning(idxValid),r.transferEffitiency(ii,idxValid)',initParams(ii,:),lowerVals(ii,:),upperVals(ii,:));
            end
        end
        if fitFlag
        fits(:,ii) = fitobject(freqs);
        rsquared(ii) = gof.rsquare;
        fitCents(ii) = fitobject.center;
        end
    end
    %fit result both to a*abs(x-b)+c and to a*(x-b)^2+c, which ever fits
    %better, take
        %crate the magnetic field vector, based on measured values for the
    %bias coils slopes (found in File is: D:\Box Sync\Lab\ExpCold\Lab log\Bias coils\bias coil field measurements.xls) 
    switch p.BiasScanDirection
        case {'x', 'X'}
            baisField = p.loopVals{2}*4.35;
        case {'y','Y'}
            baisField = p.loopVals{2}*8.49;
        case {'z','Z'}
            baisField = p.loopVals{2}*12.09;
    end
%     currs = p.loopVals{2}*1e3; %in mA, no longer relevant
    if length(p.loopVals{2})~=1 && fitFlag   
        x = baisField';
        dx = abs(x(2)-x(1));
        paddedX = linspace(min(x),max(x),200);
        y = abs(fitCents)'/(0.7); %Transform y into mGauss
%         y = abs(fitCents)';
        [c,bInd]  = min(y);
        b = x(bInd);
        if bInd ~= length(y)
            a2 = (y(bInd+1)-c)/(x(bInd+1)-b)^2;
            a3 = (y(bInd+1)-c)/abs(x(bInd+1)-b);
        else
            a2 = (y(bInd)-c)/(x(bInd)-b)^2;
            a3 = (y(bInd)-c)/abs(x(bInd)-b);
        end
        initParams2 = [a2,b,c];
        lowerVals2 = [a2-10*a2,b-dx,c-10];
        upperVals2 = [a2+10*a2,b+dx,c+10];
        initParams3 = [a3,b,c];
        lowerVals3 = [a3-10*a3,b-dx,c-10];
        upperVals3 = [a3+10*a3,b+dx,c+10];
        
        fitfunc2 =@(a,b,c,x) a*(x-b).^2+c;
        ft2 = fittype(fitfunc2,'independent','x', 'dependent','y','coefficients',{'a','b','c'});
        opts2 = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts2.StartPoint = initParams2;
        opts2.Lower=lowerVals2;
        opts2.Upper=upperVals2;
        [fitobject2,gof2,~] =fit(x,y,ft2,opts2);
        fitfunc3 =@(a,b,c,x) a*abs(x-b)+c;
        ft3 = fittype(fitfunc3,'independent','x', 'dependent','y','coefficients',{'a','b','c'});
        opts3 = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts3.StartPoint = initParams3;
        opts3.Lower=lowerVals3;
        opts3.Upper=upperVals3;
        [fitobject3,gof3,~] =fit(x,y,ft3,opts3);
        if gof3.rsquare>gof2.rsquare
            bestFit =fitobject3;
        else
            bestFit =fitobject2;
        end
        hold(ax1,'on');
        plot(ax1,paddedX,bestFit(paddedX))
        text(ax1,bestFit.b,bestFit.c,sprintf('\\leftarrow %1.1f',bestFit.b))
    end
    if fitFlag
    plot(ax1,baisField,y,'o');
% plot(ax1,currs,abs(fitCents),'o') 
    xlabel(ax1,sprintf('%s Magnetic compensation field [Gauss]',upper(p.BiasScanDirection)))
    ylabel(ax1,'Magnetic field [mGauss]')
    title(ax1,'Magnetic field vs bias field');
    legend(ax1,'data','fit')
    set(ax1,'FontSize',12);
    end
    hold(ax2,'on')
    if length(p.loopVals)>1&&   length(p.loopVals{2})>1
        for ii=1:length(p.loopVals{2})
            plot(ax2,r.detuning,r.transferEffitiency(ii,:)+(ii-1)*0.1,'-','DisplayName',num2str(p.loopVals{2}(ii)))
            %         plot(ax2,r.detuning(HWHMInd(ii)),r.transferEffitiency(ii,HWHMInd(ii))+(ii-1)*0.1,'xr')
            if fitFlag
            plot(ax2,freqs,fits(:,ii)+(ii-1)*0.1)
            end
            %         legendList{ii} = sprintf('HH%s current %0.2f [mA]',upper(p.BiasScanDirection),p.loopVals{2}(ii)*1e3);
        end
        %     legend(ax2,legendList,'Location','northwest','FontSize',6);
    else
        plot(ax2,r.detuning,r.transferEffitiency,'-');
        if fitFlag
        plot(ax2,freqs,fits)
        end
    end
    xlabel(ax2,'MW detuning [kHz]');
    title(ax2,'Transfer efficiency');
    set(ax2,'FontSize',12);
    warning('on');
    legend(ax2)
catch err
    if strcmpi('MATLAB:badsubscript',err.identifier) && (nargin == 3 || varargin{1} ~= 1)
        app.validfileLamp.Color='r';
    end
    errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
        err.stack(1).name, err.stack(1).line, err.message);
    error(errorMessage)
end

