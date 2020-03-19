clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='function generator test';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
p.hasScopResults=0;
p.hasPicturesResults=0;
p.FunctionGen = 1;
initinst
initr


%%
p.oscPeriod = 5;
p.oscTime = 2e6;
p.s=sqncr();
% p.s.addBlock({'Load MOT'});
p.s.addBlock({'setRigolModParams','channel',1,'bias',8,'modulation',4,'freq',p.oscPeriod});
p.s.addBlock({'setRigolBurstMode','channel',1,'mode','gat'});
p.s.addBlock({'setRigolBurstState','channel',1,'state',1});
p.s.addBlock({'pause','duration',1e6});
p.s.addBlock({'setDigitalChannel','channel','RigolTTL','value','high','duration',p.oscTime});
p.s.addBlock({'pause','duration',p.oscTime});
p.looping = int16(1);
p.s.run();
%%