clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=1;
p.hasPicturesResults = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr

p.looping=1;
p.expName = 'SlowModeSpectroscopyControlPowerScan';
%%
p.stepTime = 1;
p.freqNum = 50;
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 20;
p.probeDet = -4;
p.probeLockCenter = 400+p.probeDet;
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2,0,1e-1*p.freqNum,p.freqNum)
p.s=sqncr();
% p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
p.s.addBlock({'Load MOT'});
p.s.runStep;

p.NAverage = 15;
p.repumpTime = 1;
p.tofTime = 1000;
p.DTParams.TrapTime = 4e4;
p.DTParams.MOTLoadTime = 1;
p.MOTReloadTime = 1;
p.chanList = 4;
p.slowModePost = 1;
p.pauseBetweenRunSteps = 0.001;
% p.probeDet =0;
p.loopVals{2} = linspace(1e-3,0.02,1);
% p.loopVals{2} = linspace(1e-2,1e-2,1);
p.loopVars{2} = 'controlPower';
p.(p.loopVars{2}) = p.OUTERLOOPVAR;

p.loopVals{1} = ((1:p.freqNum)-1)*p.stepTime;
p.loopVars{1} = 'freqJumpPause';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.freqs = linspace(-p.probeRampSpan/2,p.probeRampSpan/2,length(p.loopVals{1}));
p.messTime = 15;
p.probeNDList = 3;
p.Control776NDList = 2;
p.s=sqncr();
p.s.addBlock({'set776ControlPower','channel','ImagingVVAN','value',p.controlPower,'duration',0});
p.s.addBlock({'syncSetProbeAOMFreq','freqJumpPause',p.freqJumpPause});
% p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
% p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
% p.s.addBlock({'pause','duration',1e4});
p.s.addBlock({'setProbePower','duration',0,'value',10e-6,'channel','PRBVVAN'})
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
%repump
for ii = 1:10
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high','description','REPUMP OFF'});
p.s.addBlock({'pause','duration',40});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','REPUMP OFF'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',100});
end
%tof
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.tofTime});
%measure
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','value','high','duration',p.messTime});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',p.messTime,'value','high'});
p.s.addBlock({'pause','duration',p.messTime});


p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e5});
p.s.run();
%%
r.scopeRes{1}(r.scopeRes{1}==0) = nan;
meanTrans = squeeze(mean(r.scopeRes{1},5));
figure;
plot(p.freqs,meanTrans)