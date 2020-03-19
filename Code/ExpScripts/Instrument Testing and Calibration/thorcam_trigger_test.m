%thorcam triggering test
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
p.hasPicturesResults=1;
p.picsPerStep=20;
p.pfLiveMode=1;
p.tcLiveMode=0;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr

%%

p.s=sqncr();
p.s.addBlock({'pause','duration',200});
p.s.addBlock({'TrigScope'});
for ind=1:1
p.s.addBlock({'setDigitalChannel','channel','ThorcamTrig','duration',0,'value','high','description','picture:trigger photo'});
p.s.addBlock({'pause','duration',65e3});
end
p.s.run();


size(r.images{2})
