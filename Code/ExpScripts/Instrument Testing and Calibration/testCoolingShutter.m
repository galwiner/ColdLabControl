clear all;
instrreset;
global p;
global r;
global inst;
initp;
p.hasScopResults = 1;
p.expName = 'test cooling shutter';
initinst;
initr;
 %%

p.s = sqncr;
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','high'});
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','low'});
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'forEnd','value',50});
p.s.run;
