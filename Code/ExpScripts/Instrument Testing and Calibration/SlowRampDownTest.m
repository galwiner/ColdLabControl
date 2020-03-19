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
p.numOfScopPoints = 5000;
p.HHZCurrent = 0.0232;
initinst
initr
inst.scopes{1}.setTimeMode('main');
inst.scopes{1}.setTimebase(0.1);

p.expName = 'Slow Ramp Down Test';

p.s = sqncr;
p.s.addBlock({'Release MOT'})
p.s.addBlock({'pause','duration',1e5});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.coolingPower});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',1e4});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'GenPause','duration',p.MOTLoadTime});
p.s.run();
r.LightBg = max(r.scopeRes{1}(:,3));

%%
p.DDS1RampUpFreq = 110;
p.DDS1RampDownFreq = 89.1060;
p.MOTReloadTime = 100e3;
p.compressionTime = 50e3;
p.compressionRampTime = 20e3;
p.pauseBetweenRunSteps = 1e-3;
p.compressionEndCurrent = 40;
p.MOTReleaseTime = 1/40;
nInnerLoop = 5; %MW detuning
nOuterLoop = 2; %Hold Time
resonanceFreq = 34.678261;
startDet = -430;
startFreq = startDet/1e3+resonanceFreq;
endDet = -100;
endFreq = endDet/1e3 + resonanceFreq;
startHoldTime = 0.1e3;
endHoldTime = 8e3;
MWFreqs=linspace(startFreq,endFreq,nInnerLoop);%34.678261 is the theoretical resonance
holdTimeVals = linspace(startHoldTime,endHoldTime,nOuterLoop);
p.loopVals={MWFreqs,holdTimeVals};
p.loopVars = {'MWFreq','holdTime'};
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.(p.loopVars{2})=p.OUTERLOOPVAR;
p.MWPulseTime = 120;
p.flashTime = 400;
imagePause = max(p.cameraParams{1}.E2ExposureTime,p.cameraParams{2}.E2ExposureTime);
p.settleTime = 1/40;
p.rampStepTime = 7.5;
%Set up cooling AOM DDS scan, for compression
p.s=sqncr();
p.s.addBlock({'SetupDDSSweepUpDown','channel',1,'UpFreq',p.DDS1RampUpFreq,'DownFreq',p.DDS1RampDownFreq,'symmetric',0,'UpTime',50,'downTime',p.compressionRampTime});
p.s.runStep;
%start seq
p.s=sqncr();
p.s.addBlock({'SetMWFreq','frequency',p.MWFreq}); %setup MW freq
%ramp up circ coil current
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionRampTime,'EndCurrent',p.compressionEndCurrent});
%start detuning ramp
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.compressionTime,'value','low','inverted','true'});
p.s.addBlock({'pause','duration',p.compressionTime}); %pause for compression
%Release MOT and Hold, and measure MW resonance.
p.s.addBlock({'Release MOT'})
%Star slow ramp down
% p.s.addBlock({'forStart'});
% p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',p.rampStepTime,'value','low','inverted','true'});
% p.s.addBlock({'pause','duration',p.rampStepTime+10});
% p.s.addBlock({'forEnd','value',20});
% p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',0,'value','low'});
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',13.7,'value','low','inverted','true'});
p.s.addBlock({'pause','duration',60});
p.s.addBlock({'forEnd','value',20});
p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',0,'value','low'});
%end of slow ramp down, start chrck eddy
p.s.addBlock({'pause','duration',p.settleTime})
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.holdTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.holdTime,'value','high'});
p.s.addBlock({'pause','duration',p.holdTime});
% p.s.addBlock({'TakePic'});
%turn on cooling
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
%pause for flash time
p.s.addBlock({'pause','duration',p.flashTime});
%flash with MW
p.s.addBlock({'setDigitalChannel','channel','MWSourceSwitch','value','high','duration',p.MWPulseTime});
p.s.addBlock({'pause','duration',p.MWPulseTime});
%2nd flash
p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePicForMWSpectro'});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
p.looping = int16(1);
% runtmr = tic;
p.s.run();
% toc(runtmr)

%%
% imageViewer(r.images{1}(:,:,:))
f = figure;
plotter_EddyCurrentDecay(f,p,r,1);
