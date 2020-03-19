clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
% p.expName='g2';
p.hasScopResults=0;
p.hasPicturesResults=0;
p.hasTTresults=1;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr

%%
p.TTbinsPerStep=100;
p.s = sqncr;
p.s.addBlock({'startTTraw','Buffer_size',30e6,'chan1',1,'chan2',2,'measTime',5e6,'min_time',-100e6,'max_time',200e6,'bin_size',1e6});
% p.s.addBlock({'startTTgatedCount','countVectorLen',p.TTbinsPerStep});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',1/40})
p.s.addBlock({'pause','duration',5e6})
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',1/40})
p.s.run();

figure;plot(r.g2Vect)
% assert(isnan(r.g2Vect)~=1)
high3=find(r.corrRes(2,:)==3)


