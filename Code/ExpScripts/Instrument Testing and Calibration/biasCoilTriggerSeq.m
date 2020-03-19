%bias coil trigger test

clear all
imaqreset
global p

global r
global inst
DEBUG=0;
% init(DEBUG);
initp

p.hasScopResults=0;
p.hasPicturesResults=0;
p.picsPerStep=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
% p.expName = 'biasTrig sequence';

initinst
initr

%%setup bias coil pulse

psu=inst.BiasCoils{1};
psu.configTriggedPulse(0.00001,1)

%% setup seq

p.s=sqncr();
% p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',100,'value','High','description','trig bias coil'});
p.looping = int16(1);
p.s.run();
