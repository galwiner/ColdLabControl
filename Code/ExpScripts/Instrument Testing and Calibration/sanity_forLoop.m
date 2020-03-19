clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=1;
p.hasPicturesResults = 0;
p.hasTTresults = 1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
p.looping=1;
% p.expName = 'Fast Mode Spectroscopy With SPCM';
%%
p.s=sqncr();
p.s.addBlock({'TrigScope'});
for ind=1:1
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','value','high','duration',10});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'forEnd','value',3});
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','value','high','duration',10});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'forEnd','value',65000});
end
p.s.run();
