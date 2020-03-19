%cooling power sweep with fast mode spectroscopy
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
p.picsPerStep = 1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=0;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
initinst
initr
p.finalCoolingPower = 100; %im mW
p.PowerRampTime = 1e3; %in \mus
%% 
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',p.PowerRampTime,'EndPower',p.finalCoolingPower});
p.s.addBlock({'pause','duration',2*p.PowerRampTime});
p.s.addBlock({'Release MOT'});
p.looping = int16(1);
p.s.run();

% figure;
% imagesc(r.images{1}-r.bgImg{1});
imageViewer(r.images{1}-r.bgImg{1})