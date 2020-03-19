%control and probe alignment script: turn on control, probe and MOT 

clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=0;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr
%load the MOT
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0,'description','probe on'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0,'description','Control beam on'});

p.looping = int16(1);
p.s.run();
