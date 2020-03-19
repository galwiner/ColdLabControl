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
p.hasTTresults = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
p.chanList = [2,3,4];
initinst
initr
p.looping=1;

%%
p.expName = 'Dipole Trap Beam Shift';
p.gateNum = 2000;
p.NAverage = 50;
p.innerLoopDelay = 1;
p.DTParams.MOTLoadTime = 0.5e6;
p.gateTime = 20;
p.DTParams.TrapTime = 1;
p.repumpTime = 100;
% testLock()
p.s=sqncr();
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %this must be at least 10 ms, to let the magnetic field time to settle
%zeeman pump
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',3,'value','high'});
p.s.addBlock({'pause','duration',3});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter. 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trappcloing time
%measure
p.s.addBlock({'forStart'});
p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.gateNum});
%reset
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();
%
ind1 = 1350;
ind2 = 1.781e4;
xDat = squeeze(r.scopeRes{1}(ind1:ind2,4,:));
yDat = squeeze(r.scopeRes{1}(ind1:ind2,5,:));
pDat = squeeze(r.scopeRes{1}(ind1:ind2,3,:));
figure;
subplot(3,1,1)
% plot(mean(xDat,1));
plot(xDat);
legend
% imagesc(xDat)
subplot(3,1,2)
% plot(mean(yDat,1));
plot(yDat);
legend

% imagesc(yDat)
subplot(3,1,3)
% imagesc(pDat)
% plot(mean(pDat,1));
plot(pDat);
legend
