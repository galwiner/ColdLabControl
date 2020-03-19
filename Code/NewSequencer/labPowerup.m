%labShutdown

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

cl=inst.Lasers('cooling');
rp=inst.Lasers('repump');


fprintf('switching on cooling,repump lasers');
cl.setLaserStat('on');
rp.setLaserStat('on');




p.s=sqncr();
p.s.addBlock({'Release MOT'})
p.s.run();
