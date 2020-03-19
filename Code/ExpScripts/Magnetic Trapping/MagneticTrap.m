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
p.postprocessing=0;
p.DEBUG=DEBUG;
p.coolingDet = -3*p.consts.Gamma;
initinst
initr


p.expName='Magnetic Trap';
psu=inst.BiasCoils{1};
p.probeRampTime = 400;
p.probeRampSpan = 300;
p.probeLockCenter = 5628;
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,32)
p.NAverage=1;
% p.FeedForward = 0.25;
% sc=keysightScope('10.10.10.118','MOTSCOPE','ip');
%%
% sc.setState('single')
% p.zeemanPumpTime=40;
% p.zeemanBiasCurrent=-0.2;
% p.zeemanBiasTime = 2e3;
% psu.configTriggedPulse(p.zeemanBiasCurrent,p.zeemanBiasTime);
p.compressionEndCurrent = 220;
p.compressionTime = 20e3;

p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low',});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',p.compressionEndCurrent});
p.s.addBlock({'pause','duration',70e3});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'setAnalogChannel','channel','CircCoil','duration',0,'value',p.circCurrent*10/220});
p.s.addBlock({'GenPause','channel','none','value','none','duration',0.5e6});
p.s.run;
figure;imagesc(r.images{1})


