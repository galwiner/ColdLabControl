clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasTTresults = 0;
p.ttDumpMeasurement = 0;
p.hasPicturesResults=0;
p.hasScopResults=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.chanList = 1;
p.runSettlingLoop=0;
initinst
initr
inst.BiasFieldManager.I=[0.0500   -0.0895    0.100];
p.expName = 'depletion_spectroscopy';
p.MOTLoadTime=5e6;
p.s=sqncr();
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.TrigScope});
p.s.run
p.MOTRefVal = mean(r.scopeRes{1}(:,2));




%%

p.M2scanMode = 1;
p.NAverage=1;
percentStart=20;
percentEnd=80;
stepSize = 2e-2;
p.loopVals{1}=percentStart:stepSize:percentEnd;
r.TisaphFreqs = zeros(size(p.loopVals{1}));
p.loopVars{1} = 'resonatorPercent';
p.(p.loopVars{1})=p.INNERLOOPVAR;

p.MOTLoadTime=1e6;
p.s=sqncr();
p.s.addBlock({p.asyncActions.setResonatorPercent,'value',p.resonatorPercent});
p.s.addBlock({'pause','duration',1e6})
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.TrigScope});
p.s.run();



%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
%%
meanScpRes = squeeze(mean(r.scopeRes{1}(:,2,:),1));
meanScpRes(meanScpRes==0) = nan;
p.LightBG = 0.7334;
notmSpect = (meanScpRes-p.LightBG)/(p.MOTRefVal-p.LightBG);
plotVals = (r.TisaphFreqs-r.TisaphFreqs(1))*2*1e3;
co = colororder;
figure;
plot(plotVals,notmSpect,'o-','MarkerEdgeColor',co(1,:))
hold on
ylims = ylim;
nList = 85:97;
sn = nList;
d32n = sn;
d52n = sn;
sLines = (getRydbergTransFreq(nList)-r.TisaphFreqs(1)*2)*1e3;
d32Lines = (getRydbergTransFreq(nList,2,3/2)-r.TisaphFreqs(1)*2)*1e3;
d52Lines = (getRydbergTransFreq(nList,2,5/2)-r.TisaphFreqs(1)*2)*1e3;
plotLims = [min(plotVals)-(max(plotVals)-min(plotVals))*0.01,max(plotVals)+(max(plotVals)-min(plotVals))*0.01];
sn(sLines<plotLims(1)|sLines>plotLims(2)) = [];
d32n(d32Lines<plotLims(1)|d32Lines>plotLims(2)) = [];
d52n(d52Lines<plotLims(1)|d52Lines>plotLims(2)) = [];
sLines(sLines<plotLims(1)|sLines>plotLims(2)) = [];
d32Lines(d32Lines<plotLims(1)|d32Lines>plotLims(2)) = [];
d52Lines(d52Lines<plotLims(1)|d52Lines>plotLims(2)) = [];
for ii = 1:length(sLines)
       plot(sLines(ii)*ones(1,100),linspace(ylims(1),ylims(2),100),'--k')
       text(sLines(ii),ylims(1)+(ylims(2)-ylims(1))*0.1,sprintf(' %0.0fS',sn(ii)),'fontsize',12)
end
% plot(plotVals,spect2,'o-','MarkerEdgeColor',co(1,:),'Color',co(1,:))
% plot(plotVals,spect3,'o-','MarkerEdgeColor',co(1,:),'Color',co(1,:))

for ii = 1:length(d32Lines)
       plot(d32Lines(ii)*ones(1,100),linspace(ylims(1),ylims(2),100),'--k')
       text(d32Lines(ii),ylims(1)+(ylims(2)-ylims(1))*0.1,sprintf(' %0.0fD_{3/2}',d32n(ii)),'fontsize',12)
end
for ii = 1:length(d52Lines)
       plot(d52Lines(ii)*ones(1,100),linspace(ylims(1),ylims(2),100),'--k')
       text(d52Lines(ii),ylims(1)+(ylims(2)-ylims(1))*0.2,sprintf(' %0.0fD_{5/2}',d52n(ii)),'fontsize',12)
end
% set(gca,'XTick',linspace(min(plotVals),max(plotVals),20))
% set(gca,'XTickLabel',round(linspace(0,(max(plotVals)-min(plotVals))*1e3,20),1))
xlabel(sprintf('Blue laser frequency relative to %0.5f [THz]', r.TisaphFreqs(1)*2));
ylabel('Relative MOT intensity');
set(gca,'fontsize',30)
legend('Depletion spectroscopy','Literature','fontsize',20)
ylim([0,1.2])
grid('minor')
