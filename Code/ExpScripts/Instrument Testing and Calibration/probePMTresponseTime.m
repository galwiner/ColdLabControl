clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp

p.hasScopResults=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
p.looping=1;
p.expName = 'Probe PMT response time calibration';
%%
% inst.DDS.setFreq(1,63,0,0);
pause(0.3)
p.s=sqncr();
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',10000,'value','high'});
p.s.run();
%%
