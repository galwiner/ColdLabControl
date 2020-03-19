%fast mode spectroscopy on a cold cloud, in live camera mode
% clear all
global p

global r
global inst

% if ~checkLoaded
    

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
initinst
initr
p.expName = 'Find Slow Ramp Down';

%%
p.DDS1RampUpFreq = 110;
p.DDS1RampDownFreq = 89.1060;
p.MOTReloadTime = 100e3;
p.compressionTime = 50e3;
p.compressionRampTime = 20e3;
p.pauseBetweenRunSteps = 1e-3;
p.compressionEndCurrent = 40;
p.MOTReleaseTime = 1/40;
p.rampStepTime =13.7;
%start seq
p.s=sqncr();
%Set up cooling AOM DDS scan, for compression
p.s.addBlock({'SetupDDSSweepUpDown','channel',1,'UpFreq',p.DDS1RampUpFreq,'DownFreq',p.DDS1RampDownFreq,'symmetric',0,'UpTime',50,'downTime',p.compressionRampTime});
%ramp up circ coil current
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionRampTime,'EndCurrent',p.compressionEndCurrent});
%start detuning ramp
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.compressionTime,'value','low','inverted','true'});
p.s.addBlock({'pause','duration',p.compressionTime}); %pause for compression
%Release MOT and Hold, and measure MW resonance.

p.s.addBlock({'Release MOT'})
p.s.addBlock({'TrigScope'});
%Star slow ramp down
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',p.rampStepTime,'value','low','inverted','true'});
p.s.addBlock({'pause','duration',60});
p.s.addBlock({'forEnd','value',20});
p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',0,'value','low'});
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
