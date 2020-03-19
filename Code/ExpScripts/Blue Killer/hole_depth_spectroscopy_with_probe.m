clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasTTresults = 1;
p.ttDumpMeasurement = 1;
p.hasPicturesResults=0;

initinst
initr
p.probePower=3e-9; %in mW6
SetProbePower(p.probePower,p.probeNDList)
loadNoise;
p.MOTLoadTime=8e6;
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'Load MOT'});
p.s.runStep
p.expName = 'Hole depth spectroscopy';
inst.BiasFieldManager.I=[0.0300   -0.0850    0.0900]; %B field values to center MOT on camera
p.runSettlingLoop=0;
%%
p.gateTime = 2e3;
p.flashTime=20;
p.BLUE_HOLE_Time = 1e3;
p.MOTReloadTime = 3e5;
p.NAverage=5;
p.nInner = 15;
p.loopVals{1}=linspace(RydbergDet2synthHDFreq(-30),RydbergDet2synthHDFreq(0),p.nInner);
resetControlLock(p.loopVals{1}(1));
p.loopVars{1} = 'TS_Detuning';
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.hole_TOF_Time=1;
p.tofTime = 0.5e3;
resetControlLock(p.loopVals{1}(1));
p.s=sqncr();
p.s.addBlock({p.asyncActions.setSynthHDFreq,'channel','A','freq',p.TS_Detuning});
p.s.addBlock({p.atomicActions.pause,'duration',1e5});
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.coolingSwitch,'value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.repumpSwitch,'value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'pause','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.coolingSwitch,'value','high','duration',p.hole_TOF_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.repumpSwitch,'value','high','duration',p.hole_TOF_Time});
p.s.addBlock({'pause','duration',p.hole_TOF_Time});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'});
p.s.addBlock({'pause','duration',5e3});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ProbeSwitch,'duration',p.gateTime/2,'value','high'}); 
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',p.gateTime/2});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'});
p.s.addBlock({p.atomicActions.pause,'duration',10e3});
p.s.addBlock({p.compoundActions.ReloadMOT})
p.s.run();
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);



%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
r.photmat = reshape(r.ttRes.phot_per_cycle,[p.NAverage,length(p.loopVals{1})]);
r.trans = (mean(r.photmat,1)/(p.gateTime/2)-p.noiseRate)/(p.bgRate-p.noiseRate);
figure;
plot(synthHDFreq2RydbergDet(p.loopVals{1}), r.trans)    
