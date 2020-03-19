clear all
global p

global r
global inst
initp
p.expName='Dipole Trap Power Modulation Test';
p.hasScopResults=1;
p.FunctionGen = 1;
p.hasPicturesResults=0;
p.picsPerStep=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
initinst
initr


%%
oscFreq = 100;
p.oscTime = (10/100)*1e6;
p.s = sqncr;
p.s.addBlock({'setRigolBurstMode','channel',1,'mode','gat'});
p.s.addBlock({'setRigolBurstState','channel',1,'state',1});
p.s.addBlock({'setRigolModParams','channel',1,'bias',0,'modulation',3,'freq',oscFreq});
% p.s.addBlock({'setDigitalChannel','channel','RigolTTL','value','high','duration',10});
p.s.addBlock({'pause','duration',1e6});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',p.oscTime/2});
p.s.addBlock({'setDigitalChannel','channel','RigolTTL','value','high','duration',p.oscTime});

p.s.addBlock({'pause','duration',p.oscTime});
p.looping = int16(1);
p.s.run();

