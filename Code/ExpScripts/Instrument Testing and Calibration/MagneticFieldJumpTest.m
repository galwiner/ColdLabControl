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
p.hasTTresults = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr

p.looping=1;
p.expName = 'MagneticFieldJumpTest';
%%
p.MagJumpTime = 1e3;
inst.BiasFieldManager.configBpulse([NaN,1,NaN],p.MagJumpTime);
p.s=sqncr();
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});

p.s.addBlock({'GenPause','duration',5e4});
p.s.run();