%fast mode spectroscopy on a cold cloud, in live camera mode

clear all
global p

global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.picsPerStep = 1;
p.cameraParams{1}.E2ExposureTime = 200;
initinst
initr
p.s = sqncr;
%get bg scope
p.s.addBlock({'Release MOT'})
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high','description','MW spectro:cooling laser on'});
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'TrigScope'});
p.s.run;
p.hasPicturesResults=1;
p.pfLiveMode=0;
p.tcLiveMode=0;
r.bgscope = r.scopeRes{1};
p.expName = 'SingleMOTMWPulses';
% scp = keysightScope('10.10.10.118','MOTSCOPE','ip');
% numSteps = 30;
% MWPulseTimes=linspace(50,350,numSteps);
% p.loopVals={MWPulseTimes};
% p.loopVars = {'MWPulseTime'};
% p.(p.loopVars{1})=p.INNERLOOPVAR;
p.coolingDet = -3*p.consts.Gamma;
p.PGCDetuning  = -10*p.consts.Gamma;
AOMcentFreq = 110;
span = abs(p.PGCDetuning-p.coolingDet)/2; %/2 because of double pass
center = AOMcentFreq-span/2;
p.PGCFreqRampTime = 500;
UpFreq = 110;
DownFreq = UpFreq - span;
p.s = sqncr;
p.s.addBlock({'SetupDDSSweepUpDown','channel',1,'UpFreq',UpFreq,'DownFreq',DownFreq,'symmetric',0,'UpTime',50,'downTime',p.PGCFreqRampTime});
p.s.runStep;
% inst.DDS.setupSweepMode(1,center,span,p.PGCFreqRampTime,1)
%%
p.MWPulseTimeBin = 20;
p.PGCTime = 1e4;

% p.s.getbgImg;
% scp.setState('single');
p.MOTReleaseTime = 1;
p.NumOfMWPUlses = 60;
p.flashTime = 500;
imagePause = max(p.cameraParams{1}.E2ExposureTime,p.cameraParams{2}.E2ExposureTime);
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.PGCTime,'value','low','inverted','true','description','PGC: DDS CTRL'});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',p.PGCFreqRampTime,'EndPower',300});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime,'value','high','description','PGC: Cooling ON'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime,'value','high','description','PGC: Repump ON'});
p.s.addBlock({'pause','duration',p.PGCTime,'description','PGC: pause during PGC'});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',880,'description','picture: cooling power max'});
p.s.addBlock({'pause','duration',100});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
p.s.addBlock({'pause','duration',p.flashTime});
p.s.addBlock({'TrigScope'});
for ii = 1:10
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
p.s.addBlock({'pause','duration',1.25*p.flashTime});
end
% p.s.addBlock({'pause','duration',12.5*p.flashTime});
for ii = 1:p.NumOfMWPUlses
p.s.addBlock({'setDigitalChannel','channel','MWSourceSwitch','value','high','duration',ii*p.MWPulseTimeBin});
p.s.addBlock({'pause','duration',ii*p.MWPulseTimeBin});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
p.s.addBlock({'pause','duration',1.25*p.flashTime});
end
p.s.addBlock({'GenPause','duration',p.flashTime});
p.looping = int16(1);
p.s.run();