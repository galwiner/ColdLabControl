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
p.FunctionGen=1; %for the rigol
p.chanList = 1;
p.runSettlingLoop=0;
p.numOfScopPoints = 5e3;
initinst
initr
inst.BiasFieldManager.I=[0.0500   -0.0895    0.100];


p.expName = 'depletion_spectroscopy_with_AC_field';

p.MOTLoadTime=0.25e6;
p.loopVals = {};
p.loopVars = {};
p.s=sqncr();
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.rigolGate,'value','low','duration',0});
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
% p.Efield = 0;
% inst.BiasE.setZField(p.Efield);
p.ACEfieldfreq=100;
p.ACEfieldAMP=0;
p.trigPulseTime = 3000;
% ChannelToggler('rigolGate',0);
% inst.rigol1.configBurstAntiPhaseSqu(p.ACEfieldfreq,p.ACEfieldAMP);
% pause(1);
% ChannelToggler('rigolGate',1);
r.EFieldSetTime = datetime;
p.M2scanMode_Analog=0;
p.M2scanMode = 1;
p.NAverage=1;
Vstrat = 0.6;
Vend = 0.3;
dv = -1.2e-2;
p.loopVals{1}=Vstrat:dv:Vend;
p.loopVars{1} = 'resonatorSlowV';
p.(p.loopVars{1})=p.INNERLOOPVAR;
for ii = 1:3

p.MOTLoadTime=0.25e6;
r.measureStatTime(ii) = datetime;
p.s=sqncr();
% p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.rigolGate,'value','high','duration',0});

p.s.addBlock({p.atomicActions.setAnalogChannel,'value',p.resonatorSlowV,'channel',p.chanNames.SolsTisSlow,'duration',0});
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.TrigScope});
% p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.rigolGate,'value','low','duration',0});
p.s.run();
%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
meanScpRes = squeeze(mean(r.scopeRes{1}(:,2,:),1));
meanScpRes(meanScpRes==0) = nan;

notmSpect = (meanScpRes-p.LightBG)/(p.MOTRefVal-p.LightBG);
plotVals = (r.TisaphFreqs-getRydbergTransFreq(91,1,0.5)/2)*2*1e3;
plotValsIntrp = interpVec(plotVals);
co = colororder;
figure;
plot(plotValsIntrp,notmSpect,'o-')
title(sprintf('91P spectro, at E=%0.1f V',p.ACEfieldAMP))
resetSolsTissResonatorSlow(Vend,Vstrat)
end
% ChannelToggler('rigolGate',0);