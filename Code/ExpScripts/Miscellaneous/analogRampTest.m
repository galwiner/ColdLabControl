%test analog ramp

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
p.hasPicturesResults=0;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr
%% test ramp
p.compressionTime = 5e5; %in us
p.compressionEndCurrent=0;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
% p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','value','High','duration',0});
% p.s.addBlock({'setAnalogChannel','channel','CircCoil','value',100*10/220,'duration',0});
% p.s.addBlock({'pause','duration',100e3});
% p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger photo'});
% p.s.addBlock({'pause','duration',5e5});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',220});
p.s.addBlock({'pause','duration',p.compressionTime+4});
% p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',220});
% p.s.addBlock({'pause','duration',p.compressionTime+4});
% p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',100});
% p.s.addBlock({'pause','duration',2*p.compressionTime+4});
% p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',0});
% p.s.addBlock({'pause','duration',p.compressionTime+4});
% p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger photo'});
% p.s.addBlock({'pause','duration',1e6});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','value','High','duration',0});

p.looping = int16(1);
p.s.run();

% figure;
% subplot(3,1,1)
% imagesc(r.images{1}