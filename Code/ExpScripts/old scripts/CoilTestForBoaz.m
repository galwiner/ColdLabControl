clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='CoilTestForBoaz';

p.hasScopResults=0;
p.hasPicturesResults=0;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.DEBUG=DEBUG;
%Scan setup
initinst
initr



%%

p.s=sqncr();
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setAnalogChannel','channel','RectCoil','duration',2000e3,'value',200*10/220});
p.s.addBlock({'pause','duration',2000e3});
p.looping = int16(1);
p.s.run();

%%
% imageViewer(r.images{1});
