%cooling power sweep with fast mode spectroscopy
clear all
instrreset
imaqreset
global p

global r
global inst
DEBUG=0;

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
% p.cameraParams{1}.B1BinningHorizontal = '01';
% p.cameraParams{1}.B2BinningVertical = '01';
% p.cameraParams{2}.B1BinningHorizontal = '01';
% p.cameraParams{2}.B2BinningVertical = '01';
% p.DTPos{2}(1) = 525;
% p.DTWidthHight{2} = [50,200];
% p.DipoleTrapROI{2} = calculateROI(p.DTPos{2}(1),p.DTPos{2}(2),p.DTWidthHight{2}(2)...
%     ,p.DTWidthHight{2}(1));
% p.cameraParams{2}.ROI = [870,360,500,500];
p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
% p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
p.cameraParams{2}.E2ExposureTime = 1e3;
p.idsMonitor = 0;
initinst
initr
p.expName = 'Dipole Trap Sanity Test';
%%
p.flashTime = 250;
p.DTParams.TrapTime = 2e4;
% figure;
for i=1:1
p.s = sqncr;
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','coolingShutter','duration',0,'value','high'});
p.s.addBlock({'pause','duration',5e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',2e4});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({p.compoundActions.ReloadMOT});
% p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','high'});
p.s.run

% imagesc(r.images{2}(400:600,550:750))
% colorbar
% axis equal
% axis tight
end

figure;
subplot(2,1,1)
imagesc(r.images{1})
colorbar
axis equal
axis tight
hold on
plot(p.DTPos{1}(1),p.DTPos{1}(2),'rx')
title('considered OK when peak value ~ 1000')
subplot(2,1,2)
% imagesc(r.images{2})
imagesc(r.images{2}(400:600,550:750))
colorbar
axis equal
axis tight
