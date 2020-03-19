%cooling power sweep with fast mode spectroscopy
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=0;
p.hasPicturesResults=0;
p.picsPerStep = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;

initinst
initr

p.expName = 'IGBT Test With Eyal';

%% 
p.circCurrent = 220;
p.CurrentTime = 1e6;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',0,'value','high','description','Load MOT:set IGBT ON'});
% p.s.addBlock( {'setCircCurrent','channel','CircCoil','duration',0,'value',p.circCurrent,'description','Load MOT:set coil current'});
% p.s.addBlock({'pause','duration',p.MOTLoadTime,'description','Load MOT:delay during mot load'});
% p.s.addBlock({'TrigScope'});
% p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',0,'value','low','description','Load MOT:set IGBT ON'});
% p.s.addBlock( {'setCircCurrent','channel','CircCoil','duration',0,'value',0,'description','Load MOT:set coil current'});
% p.s.addBlock({'pause','duration',10e3,'description','Load MOT:delay during mot load'});
% p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',0,'value','high','description','Load MOT:set IGBT ON'});
% p.s.addBlock( {'setCircCurrent','channel','CircCoil','duration',0,'value',p.circCurrent,'description','Load MOT:set coil current'});
% p.s.addBlock({'pause','duration',50e3,'description','Load MOT:delay during mot load'});
% p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',0,'value','low','description','Load MOT:set IGBT ON'});
% p.s.addBlock( {'setCircCurrent','channel','CircCoil','duration',0,'value',0,'description','Load MOT:set coil current'});

p.looping = int16(1);
p.s.run();

