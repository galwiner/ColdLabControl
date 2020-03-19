clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
p.NAverage=100;
p.expName = 'SPCM stream for quantum machines';
%%
p.s=sqncr();
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',5});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',5});
p.s.run();

