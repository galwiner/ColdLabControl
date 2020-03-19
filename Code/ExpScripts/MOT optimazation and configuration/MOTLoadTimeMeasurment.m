clear all
global p
global r
global inst
DEBUG=0;
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=1;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr
p.expName='MOT Load Time Measurment';

%%
p.MOTLoadTime = 10e6;
p.s=sqncr();
p.s.addBlock({'TrigScope'});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.run();


