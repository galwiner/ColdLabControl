clear all
global p

global r
global inst
DEBUG=0;

initp
p.hasScopResults=0;
p.hasPicturesResults=0;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr
p.expName='probe power test';
%power measured before fiber input 

p.hasScopResults=0;
%%
p.probeNDList=[];
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setProbePower','channel','PRBVVAN','value',5000,'duration',0});
% p.s.addBlock({'GenPause','channel','none','value',0,'duration',2e6});
p.s.run();
