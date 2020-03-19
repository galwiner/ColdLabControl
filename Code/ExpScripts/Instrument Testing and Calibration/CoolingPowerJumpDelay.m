clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='CoolingPowerJumpDelay';
p.hasScopResults=1;
p.hasPicturesResults=0;
p.picsPerStep=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp = 0;
p.DEBUG=DEBUG;
initinst
initr
%%
%sequence
p.s = sqncr;
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setCoolingPower','duration',0,'value',10});
p.s.run