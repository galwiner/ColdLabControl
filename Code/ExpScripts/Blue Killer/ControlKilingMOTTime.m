%
clear all
global p

global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.picsPerStep = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.NAverage = 1;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.circCurrent = 20;
initinst
initr
p.expName = 'Control Kiling MOT Time';
%% 
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',3e5});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();
