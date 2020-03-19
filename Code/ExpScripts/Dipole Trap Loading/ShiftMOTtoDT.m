%cooling power sweep with fast mode spectroscopy
clear all
imaqreset
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep = 1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=0;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.circCurrent = 20;
p.cameraParams{1}.E2ExposureTime = 1e3;
p.cameraParams{2}.E2ExposureTime = 1e3;

initinst
initr
p.expName = 'Shift MOT to DT';
%%
p.MOTLoadTime = 5e5;
figure;
for i=1:50
p.s = sqncr;
% p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'pause','duration',1e3});
% p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','low'});
% p.s.addBlock({'pause','duration',4e3});

p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',2e4});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','high'});
p.s.run

% % subplot(1,2,1)
% % imagesc(squeeze(r.images{1}))
% % colorbar
% % subplot(1,2,2)
% imagesc(10*log(squeeze(r.images{2})))
imagesc(squeeze(r.images{2}))
hold on
plot(p.DTPos{2}(2),p.DTPos{2}(1),'xr','markersize',8)
hold off
colorbar
end

