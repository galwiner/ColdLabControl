%Load MOT, cameras in live mode, 40A circular coil
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.hasScopResults=0;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr
% p.expName='bias compensation with strong and week MOT';
p.s=sqncr();
p.s.addBlock({'forStart'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',1e2});
p.s.addBlock({'forEnd','value',3});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'forStart'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',1e2});
p.s.addBlock({'forEnd','value',4});

p.s.run();