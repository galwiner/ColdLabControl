%cooling power sweep with fast mode spectroscopy
clear all
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
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{2}.B1BinningHorizontal = '01';
p.cameraParams{2}.B2BinningVertical = '01';
p.ROIWidth = 100;
p.ROIHeight = 100;
p.cameraParams{1}.ROI = [p.probePosInPixelfly(1)-p.ROIWidth/2,p.probePosInPixelfly(2)-p.ROIHeight/2,p.ROIWidth,p.ROIHeight];
p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
p.idsMonitor = 1;
initinst
initr
p.expName = 'Dipole Trap Loading Variation';
%%
p.flashTime = 250;
p.DTParams.TrapTime = 2e4;
p.NAverage = 100;
p.DTParams.MOTLoadTime = 2e6;
p.gateTime = 20;
p.gateNum = 5e3;
p.s = sqncr;
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','low'});
p.s.addBlock({'pause','duration',5e3});
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

p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',2e4});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
% p.s.addBlock({'Reload MOT'});
p.s.run

p.probePosInMonitor =[844,462];
p.MonROIWidth = 50;
p.MonROIHeight = 50;
cropIdsIms = squeeze(r.images{2}(p.probePosInMonitor(2)-p.MonROIHeight/2:p.probePosInMonitor(2)+p.MonROIHeight/2,p.probePosInMonitor(1)-p.MonROIWidth/2:p.probePosInMonitor(1)+p.MonROIWidth/2,:));
figure
subplot(2,1,1)
imagesc(1:p.NAverage,1:size(cropIdsIms,2),squeeze(sum(cropIdsIms,1)))
xlabel('Cycle #')
ylabel('Horizontol Index')
subplot(2,1,2)
imagesc(1:p.NAverage,1:size(cropIdsIms,1),squeeze(sum(cropIdsIms,2)))
xlabel('Cycle #')
ylabel('Vertical Index')

pfXProj = squeeze(sum(r.images{1}(:,30:70,1:end),1));
pfYProj = squeeze(sum(r.images{1}(:,:,1:end),2));

figure
subplot(2,1,1)
% imagesc(1:p.NAverage,size(pfXProj,1),pfXProj)
[X,Y] = meshgrid(1:size(pfXProj,1),1:p.NAverage);
waterfall(X,Y,pfXProj')
xlabel('Cycle #')
ylabel('Horizontol Index')
subplot(2,1,2)
[X,Y] = meshgrid(1:size(pfYProj,1),1:p.NAverage);
waterfall(X,Y,pfYProj')
xlabel('Cycle #')
ylabel('Vertical Index')