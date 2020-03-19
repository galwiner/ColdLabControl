clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Rigol Burst Test';
p.FunctionGen = 1;
initinst
initr
%%
p.s = sqncr;
p.s.addBlock({'setRigolModParams','channel',1,'bias',0,'modulation',1,'freq',10});
p.s.addBlock({'setRigolBurstMode','channel',1,'mode','gat'});
p.s.addBlock({'setRigolBurstState','channel',1,'state',1});
p.s.addBlock({'setDigitalChannel','channel','RigolTTL','value','high','duration',1e6});
p.s.run