
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
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
% fclose(inst.DDS.s)
% SHU2_initial_2016(1,0,1)
% DRG_LAB_2(100,80,4e-6,4e-6,10000,10000)
p.probeRampTime = 400;
p.probeRampSpan = 300;
p.probeLockCenter = 5611;
inst.DDS.setFreq(2,p.probeLockCenter/32,0,0);
% inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,32)
p.looping=1;

p.expName = 'ProbeSwipeOptimalDelayTime';
%%
% p.loopVars = {'DelayTime'};
% delayTime = linspace(100,300,5);
p.NAverage = 15;
% p.loopVals={delayTime};
% p.(p.loopVars{1})=p.INNERLOOPVAR;
% p.repumpTime = 1;
p.MOTLoadTime = 500e3;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low','description','COOLING OFF'});
% p.s.addBlock({'pause','duration',p.repumpTime});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','REPUMP OFF'});
% p.s.addBlock({'pause','duration',p.DelayTime});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',p.probeRampTime+50,'value','high'});

p.s.addBlock({'GenPause','channel','none','value',0,'duration',100e3});
% p.s.addBlock({'pause','duration',4.1e3});
p.s.run();

% figure;
% plot(r.scopeRes{1});
