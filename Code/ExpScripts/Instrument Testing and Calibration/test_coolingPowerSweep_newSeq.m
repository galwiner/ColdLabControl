%cooling power sweep test
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.hasScopResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr
% inst.DDS.setupSweepMode(2,5728,500,500,32)
% inst.DDS.setFreq(2,6000/32,0,0)
p.expName = 'cooling power ramp';

p.coolingPowerRampTime=1e3;

%% 
p.s=sqncr();
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',0});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',p.coolingPowerRampTime,'EndPower',880});
p.s.addBlock({'pause','duration',p.coolingPowerRampTime*2});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',p.coolingPowerRampTime,'EndPower',0});
p.s.addBlock({'pause','duration',p.coolingPowerRampTime*2});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',p.coolingPowerRampTime,'EndPower',880});
% p.s.addBlock({'pause','duration',p.coolingPowerRampTime*2});
% p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',p.coolingPowerRampTime,'EndPower',0});
p.looping = int16(1);
p.s.run();

