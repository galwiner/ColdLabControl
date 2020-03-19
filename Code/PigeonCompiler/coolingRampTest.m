% 'magnetic trapping for bias compensation'

clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.coolingDet = -3*p.consts.Gamma;
p.cameraParams{1}.E2ExposureTime = 700;
p.cameraParams{2}.exposure = 700;
initinst
initr

% p.expName='magnetic trapping for bias compensation';
p.picsPerStep=1;
p.NAverage=1;

%%

p.s=sqncr();
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',880,'description','Load MOT: set cooling power'});
p.s.addBlock({'TrigScope'});
% p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',2e3,'EndPower',880});
% p.s.addBlock({'pause','duration',1e3});
% p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',0,'description','Load MOT: set cooling power'});
p.s.run;
