clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.GaussianFitThreshold=0.4;
p.DEBUG=DEBUG;
p.coolingDet = -3*p.consts.Gamma;
p.PGCDetuning  = -10*p.consts.Gamma;
AOMcentFreq = 110;
span = abs(p.PGCDetuning-p.coolingDet)/2; %/2 because of double pass
center = AOMcentFreq-span/2;
p.PGCFreqRampTime = 100;
p.PGCTime=1e4;
p.settleTime=500;
initinst
initr



p.expName='ZeemanPumping cloud dynamics';
psu=inst.BiasCoils{1};

p.NAverage=1;
p.cameraParams{1}.E2ExposureTime=400;
p.loopVars={'pictureTime'};
nsteps=5;
pictureTimeVals=ceil(linspace(1e3,100e3,nsteps));
p.loopVals={pictureTimeVals};
p.(p.loopVars{1})=p.INNERLOOPVAR;
inst.DDS.setupSweepMode(1,center,span,p.PGCFreqRampTime,1)

%%
p.PGCEndCoolingPower=150;
p.step1compressionEndCurrent=100;
p.compressionEndCurrent=220;

p.zeemanPumpTime=500;
p.zeemanBiasCurrent=-0.1;
p.zeemanBiasTime = 10e3;
psu.configTriggedPulse(p.zeemanBiasCurrent,p.zeemanBiasTime);
% p.compressionEndCurrent = 100;
% p.step1compressionTime=10e3;
p.compressionTime = 100;
p.s.getbgImg();
p.s=sqncr();

p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',p.settleTime})
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.PGCTime,'value','low','inverted','true','description','PGC: DDS CTRL'});
% p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',p.PGCFreqRampTime,'EndPower',p.PGCEndCoolingPower});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime+20e3,'value','high','description','PGC: Cooling ON'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime+20e3,'value','high','description','PGC: Repump ON'});
p.s.addBlock({'pause','duration',p.PGCTime,'description','PGC: pause during PGC'});

% p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',10,'value','High'});
% p.s.addBlock({'pause','duration',300});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',p.zeemanPumpTime,'value','High'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',100,'value','High'});
p.s.addBlock({'pause','duration',p.zeemanPumpTime});
p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',0,'value','High','description','enable IGBT for magnetic trap'});
% p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.step1compressionTime,'EndCurrent',p.step1compressionEndCurrent,'description','load magnetic trap'});
% p.s.addBlock({'pause','duration',p.step1compressionTime+100});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',p.compressionEndCurrent,'description','load magnetic trap'});
p.s.addBlock({'pause','duration',p.pictureTime});
% p.s.addBlock({'Release MOT'});
% p.s.addBlock({'pause','duration',1000});

p.s.addBlock({'TakePic'});

p.s.addBlock({'pause','duration',1e3});
% p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',10,'value','High'});
p.s.addBlock({'setAnalogChannel','channel','CircCoil','duration',0,'value',p.circCurrent*10/220});
p.s.addBlock({'GenPause','channel','none','value','none','duration',0.5e6});
p.s.run;

%%
% imageViewer(r.images{1}-r.bgImg{1})
% plot(pictureTimeVals,squeeze(max(max(r.images{1}-r.bgImg{1}))),'o-')
imageViewer(r.images{1}(:,:,:),[],[],p.loopVals{1});
% figure;imagesc(r.images{1})
% colorbar