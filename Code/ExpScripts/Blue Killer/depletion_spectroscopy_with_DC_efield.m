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
p.expName = 'depletion_spectroscopy_with_DC_field';

p.MOTLoadTime=0.2e6;
p.loopVals = {};
p.loopVars = {};
p.s=sqncr();
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.CTRL480Shutter,'value','low','duration',0});
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.CTRL480Shutter,'value','high','duration',0});
p.s.run
p.MOTRefVal = mean(r.scopeRes{1}(:,2));
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
%%
p.Efield = 0;
inst.BiasE.setZField(p.Efield);
r.EFieldSetTime = datetime;
p.M2scanMode = 1;
p.NAverage=1;
Vstrat = 0.6;
Vend = 0.3;
dv = -1.2e-2;
p.loopVals{1}=Vstrat:dv:Vend;
p.loopVars{1} = 'resonatorSlowV';
p.(p.loopVars{1})=p.INNERLOOPVAR;
for ii = 1:3

p.MOTLoadTime=5e4;
r.measureStatTime(ii) = datetime;
p.s=sqncr();
p.s.addBlock({p.atomicActions.setAnalogChannel,'value',p.resonatorSlowV,'channel',p.chanNames.SolsTisSlow,'duration',0});
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.TrigScope});
p.s.run();
%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
meanScpRes = squeeze(mean(r.scopeRes{1}(:,2,:),1));
meanScpRes(meanScpRes==0) = nan;

notmSpect = (meanScpRes-p.LightBG)/(p.MOTRefVal-p.LightBG);
plotVals = (r.TisaphFreqs-312.72495)*2*1e3;
plotValsIntrp = interpVec(plotVals);
co = colororder;
figure;
plot(plotValsIntrp,notmSpect,'o-')
resetSolsTissResonatorSlow(Vend,Vstrat)

end
