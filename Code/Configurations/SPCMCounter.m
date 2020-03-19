clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='SPCM Counter';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
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
p.messTime = 1e3;
p.TTbinsPerStep = 1;
p.s = sqncr;
p.s.addBlock({'startTTgatedCount','countVectorLen',p.TTbinsPerStep});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','low','duration',0});
p.s.run
figure;
hold on
ii = 1;
while 1
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.run
pause(0.1)
plot(ii,r.cnt(1))
end


