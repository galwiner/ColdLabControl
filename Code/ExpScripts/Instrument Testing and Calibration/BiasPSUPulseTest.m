%cooling power sweep with fast mode spectroscopy
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.picsPerStep = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
initinst
initr
p.expName = 'BiasPSU Pulse Test';
%% 
inst.BiasCoils{1}.configTriggedPulse(0.5,1,0.2e6);
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','value','high','channel','BIASPSU_TRIG','duration',100});
p.s.run();

