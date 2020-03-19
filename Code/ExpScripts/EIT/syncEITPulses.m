clear all
global p
global r
global inst
initp
p.hasScopResults=1;
initinst
initr
SetProbePower(1e-11,[1,2,3])
%%
p.expName = 'sync EIT Pulses';
p.gateTime = 20;
p.ttGateDelay = 50e-3;
p.ControlDelay = 0.825;
p.ControlTurnoffDelay = 0.500;
p.ProbeTurnoffDelay = 0.500;
% p.DTTurnoffDelay
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'pause','duration',5e3});  
p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 1
p.s.addBlock({'pause','duration',p.ControlDelay});  %33
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0}); %1 
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0}); %1
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0}); %1
p.s.addBlock({'pause','duration',p.ttGateDelay});   %2
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0}); %1
p.s.addBlock({'pause','duration',p.gateTime/2-p.ttGateDelay-p.ControlDelay-p.ControlTurnoffDelay}); %345
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %1
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.ControlTurnoffDelay}); %20
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'pause','duration',p.ProbeTurnoffDelay}); %20
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});%1
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});%1
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});%1
p.s.addBlock({'pause','duration',p.gateTime/2 - p.ProbeTurnoffDelay - 0.400});%380
p.s.addBlock({'forEnd','value',20});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});%1
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});%1
p.s.run;
