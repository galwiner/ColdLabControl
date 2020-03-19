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
p.numOfScopPoints = 5e3;
initinst
initr
inst.BiasFieldManager.I=[0.0500   -0.0895    0.100];
p.expName = 'depletion_spectroscopy_vs_cooling_power';

p.MOTLoadTime=0.2e6;
p.loopVals = {};
p.loopVars = {};
p.s=sqncr();
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'pause','duration',1e5})
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.coolingSwitch,'value','high','duration',0});
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.repumpSwitch,'value','high','duration',0});
p.s.addBlock({'pause','duration',3e5})
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({'pause','duration',3e5})
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.run
p.LightBG = mean(r.scopeRes{1}(:,2));
p.MOTLoadTime=2e6;
p.loopVals{1}=linspace(100,690,10);
p.loopVars{1} = 'coolingPower';
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.s=sqncr();
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.CTRL480Shutter,'value','low','duration',0});
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.CTRL480Shutter,'value','high','duration',0});
p.s.run
p.MOTRefVal_all = squeeze( mean(r.scopeRes{1}(:,2,:)));

%%
p.MOTRefVal = 30;
p.M2scanMode = 1;
p.M2scanMode_Analog = 1;
p.NAverage=1;
Vstrat = 0.6;
Vend = 0.3;
dv = -1.2e-2;
p.loopVals{1}=Vstrat:dv:Vend;
p.loopVars{1} = 'resonatorSlowV';
p.(p.loopVars{1})=p.INNERLOOPVAR;

p.loopVals{2}=linspace(100,690,10);
p.loopVars{2} = 'coolingPower';
p.(p.loopVars{2})=p.OUTERLOOPVAR;

p.MOTLoadTime=2.5e5;
p.s=sqncr();
p.s.addBlock({p.atomicActions.setAnalogChannel,'value',p.resonatorSlowV,'channel',p.chanNames.SolsTisSlow,'duration',0});
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.TrigScope});
p.s.run();


%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
%%
meanScpRes = squeeze(mean(r.scopeRes{1}(:,2,:,:),1));
meanScpRes(meanScpRes==0) = nan;
p.MOTRefVal = repmat(p.MOTRefVal_all,1,length(p.loopVals{1}));
normSpect = (meanScpRes-p.LightBG)./(p.MOTRefVal-p.LightBG);
plotVals = (r.TisaphFreqs-312.72495)*2*1e3;
plotValsIntrp = interpVec(plotVals);
co = colororder;
figure;
hold on
for ii = 1:length(p.loopVals{2})
plot(plotValsIntrp(:,ii),normSpect(ii,:),'o-')
end
