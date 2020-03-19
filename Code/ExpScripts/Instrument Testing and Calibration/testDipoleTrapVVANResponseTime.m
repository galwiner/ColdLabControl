clear all
global p
global r
global inst
initp
p.hasScopResults=1;
initinst
initr
%%
p.expName = 'test dipole trap VVAN response time';
p.settleTime = 100;
p.s = sqncr;
p.s.addBlock({'setAnalogChannel','channel','BlueDTVVAN','value',1,'duration',0})
p.s.addBlock({'setAnalogChannel','channel','PurpleDTVVAN','value',1,'duration',0})
p.s.addBlock({'pause','duration',p.settleTime});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setAnalogChannel','channel','BlueDTVVAN','value',10,'duration',0})
p.s.addBlock({'setAnalogChannel','channel','PurpleDTVVAN','value',10,'duration',0})
p.s.addBlock({'pause','duration',p.settleTime});
p.s.run;

