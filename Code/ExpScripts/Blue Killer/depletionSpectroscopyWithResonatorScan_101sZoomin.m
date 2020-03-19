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
inst.BiasFieldManager.I=p.Blue_Killer_I;
p.expName = 'depletion_spectroscopy';
p.MOTLoadTime=2e6;
p.s=sqncr();
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.run
p.MOTRefVal = mean(r.scopeRes{1}(:,2));
p.s=sqncr();
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'pause','duration',1e5});
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.coolingSwitch,'value','high','duration',0})
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.repumpSwitch,'value','high','duration',0})
p.s.addBlock({p.compoundActions.TrigScope});
p.s.run
p.NoAtomsVal = mean(r.scopeRes{1}(:,2));
%%

p.M2scanMode = 0;
p.NAverage=1;
percentStart=44.5;
percentEnd=46.5;
stepSize = 1e-2;
p.loopVals{1}=percentStart:stepSize:percentEnd;
r.TisaphFreqs = zeros(size(p.loopVals{1}));
p.loopVars{1} = 'resonatorPercent';
p.(p.loopVars{1})=p.INNERLOOPVAR;

p.s=sqncr();
p.s.addBlock({p.asyncActions.setResonatorPercent,'value',p.resonatorPercent});
p.s.addBlock({'pause','duration',1e6})
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.run();



%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
%%
meanScpRes = squeeze(mean(r.scopeRes{1}(:,2,:),1));
meanScpRes(meanScpRes==0) = nan;
% plotVals = (r.TisaphFreqs-r.TisaphFreqs(1))*2*1e3; %move to GHz
plotVals = r.TisaphFreqs*2;
figure;
plot(plotVals,meanScpRes)
hold on
set(gca,'XTick',linspace(min(plotVals),max(plotVals),20))
ylims = ylim;
nList = 95:105;
sn = nList;
d32n = sn;
d52n = sn;
sLines = getRydbergTransFreq(nList);
d32Lines = getRydbergTransFreq(nList,2,3/2);
d52Lines = getRydbergTransFreq(nList,2,5/2);
plotLims = [min(plotVals)-(max(plotVals)-min(plotVals))*0.3,max(plotVals)+(max(plotVals)-min(plotVals))*0.3];
sn(sLines<min(plotVals)|sLines>max(plotVals)) = [];
d32n(d32Lines<plotLims(1)|d32Lines>plotLims(2)) = [];
d52n(d52Lines<plotLims(1)|d52Lines>plotLims(2)) = [];
sLines(sLines<plotLims(1)|sLines>plotLims(2)) = [];
d32Lines(d32Lines<plotLims(1)|d32Lines>plotLims(2)) = [];
d52Lines(d52Lines<plotLims(1)|d52Lines>plotLims(2)) = [];

for ii = 1:length(sLines)
       plot(sLines(ii)*ones(1,100),linspace(ylims(1),ylims(2),100),'--k')
       text(sLines(ii),ylims(1)+(ylims(2)-ylims(1))*0.1,sprintf('%0.0fS',sn(ii)),'fontsize',10)
end
for ii = 1:length(d32Lines)
       plot(d32Lines(ii)*ones(1,100),linspace(ylims(1),ylims(2),100),'--k')
       text(d32Lines(ii),ylims(1)+(ylims(2)-ylims(1))*0.1,sprintf('%0.0fD_{3/2}',d32n(ii)),'fontsize',10)
end
for ii = 1:length(d52Lines)
       plot(d52Lines(ii)*ones(1,100),linspace(ylims(1),ylims(2),100),'--k')
       text(d52Lines(ii),ylims(1)+(ylims(2)-ylims(1))*0.2,sprintf('%0.0fD_{5/2}',d52n(ii)),'fontsize',10)
end

%

figure;
imagesc(squeeze(r.scopeRes{1}(:,2,1,:)))
loadingData=squeeze(r.scopeRes{1}(:,2,1,:));
for ind=1:size(loadingData,2)
    fit(r.TisaphFreqs,loadingData(:,ind))
end


