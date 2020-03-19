clear all;
instrreset;

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
p.DEBUG=DEBUG;
p.expName = 'DDS RAMP TEST';

initinst
initr
p.RampTime=500;
p.RampSpan=300;
inst.DDS.setupSweepMode(2,5728,p.RampSpan,p.RampTime,32)
% pause(1);
% inst.DDS.setupSweepMode(2,5728,p.RampSpan,p.RampTime,32)
% pause(1);
p.s=sqncr();
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0,'description','DDS scan on'});
p.s.addBlock({'setAnalogChannel','channel','PRBVVAN','value',10.8/2,'duration',0});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','value','high','duration',p.RampTime+50,'description','DDS scan on'});

p.s.addBlock({'TrigScope'});
p.looping = int16(1);
p.s.run();
% [x,y]=inst.scopes{1}.getChan(1);
% figure;plot(x,y)
% figure;spectrogram(y)

