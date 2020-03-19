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
p.hasPicturesResults=1;
p.picsPerStep = 1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=0;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{2}.B1BinningHorizontal = '01';
p.cameraParams{2}.B2BinningVertical = '01';
p.ROIWidth = 400;
p.ROIHeight = 400;
p.cameraParams{1}.ROI = [p.probePosInPixelfly(1)-p.ROIWidth/2,p.probePosInPixelfly(2)-p.ROIHeight/2,p.ROIWidth,p.ROIHeight];
p.cameraParams{1}.ROI = [p.DTPos{1}(1)-p.ROIWidth/2,p.DTPos{1}(2)-p.ROIHeight/2,p.ROIWidth,p.ROIHeight];

p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
p.idsMonitor = 1;
initinst
initr
p.expName = 'Dipole Trap alignment';

%% 
r.images = {};
if p.idsMonitor==1
    p.DTPos{2} = [751,568];
end
idsWidth = 500;
idsROI = [p.DTPos{2}(2)-idsWidth/2,p.DTPos{2}(2)+idsWidth/2,p.DTPos{2}(1)-idsWidth/2,p.DTPos{2}(1)+idsWidth/2];
p.flashTime = 50;
p.DTParams.PurpleBeamOnly = 0;
% p.DTParams.TrapTime = 1e4;
p.NAverage = 1;
p.DTParams.TrapTime = 1;
% p.DTParams.LoadingTime = 1e5;
% p.DTParams.secondStageTime = 1;
% p.DTParams.LoadingTime = 1;
% p.DTParams.secondStageTime = 1;
p.DTParams.MOTLoadTime = 1e6;
% p.probeNDList = [1,2];
p.settlingStepN=0;
p.probePower = 1e-12;
p.NAverage = 1;
figure;
for i=1:100
p.s = sqncr;
p.s.addBlock({'setProbePower','value',p.probePower,'duration',0});
p.s.addBlock({'LoadDipoleTrap'});
% p.s.addBlock({'setDigitalChannel','channel','coolingShutter','duration',0,'value','High'});
% p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high6','duration',1000});
p.s.addBlock({'TakePic'});
% p.s.addBlock({'TakePicWithCooling'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',2e5});
% p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','high'});
p.s.addBlock({'Reload MOT'})
p.s.run
subplot(3,1,1)
imagesc(squeeze(mean(r.images{1},6)))
hold on;
plot(p.ROIWidth/2,p.ROIHeight/2,'xr','markersize',10)
axis equal
axis tight
hold off;
colorbar
subplot(3,1,2)
p.probePosInMonitor =[559,363];
% p.MonROIWidth = 300;
% p.MonROIHeight =300;
% imagesc(squeeze(r.images{2}(p.probePosInMonitor(2)-p.MonROIHeight/2:p.probePosInMonitor(2)+p.MonROIHeight/2,p.probePosInMonitor(1)-p.MonROIWidth/2:p.probePosInMonitor(1)+p.MonROIWidth/2)))
mi = [];
[~,mi] = max(r.images{2}(:));
[iy,ix] = ind2sub(size(r.images{2}),mi);

if ix+idsWidth/2>size(r.images{2},2)||ix-idsWidth/2<1||iy-idsWidth/2<1||iy+idsWidth/2>size(r.images{2},1)
    ix = p.DTPos{2}(1);
    iy = p.DTPos{2}(2);
else
    p.DTPos{2}(1)=ix;
    p.DTPos{2}(2)=iy;
    idsROI = [p.DTPos{2}(2)-idsWidth/2,p.DTPos{2}(2)+idsWidth/2,p.DTPos{2}(1)-idsWidth/2,p.DTPos{2}(1)+idsWidth/2];

end
imagesc(r.images{2}(idsROI(1):idsROI(2),idsROI(3):idsROI(4)));
% imagesc(mean(r.images{2}(:,:,:),3))
colorbar
hold on;
plot(idsWidth/2,idsWidth/2,'xr','markersize',10)
axis equal
axis tight
hold off;
% imagesc(r.images{2}(roi(1):roi(2),roi(3):roi(4)))
subplot(3,1,3)
plot(r.images{2}(idsROI(1):idsROI(2),ix));
hold on
plot(r.images{2}(iy,idsROI(3):idsROI(4)));

% hold on;
% plot(idsWidth/2,idsWidth/2,'xr','markersize',10)
annotation('textarrow',[0.1 0.3],[0.7,0.1],'String','BlueBeam');
annotation('textarrow',[0.3 0.1],[0.7,0.1],'String','PurpleBeam');
hold off;
end
