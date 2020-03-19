%estop test
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.hasScopResults=0;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr
p.s.addBlock({'TrigScope'});
p.s.addBlock({'GenPause','duration',1e6,'channel','none','value','none'});
% p.s.addBlock({'setDigitalChannel','channel','ScopeTrigger','value','low','duration',0});
p.looping = int16(10);
p.s.run();
