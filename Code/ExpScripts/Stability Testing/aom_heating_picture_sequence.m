%IDS monitor photo sequence
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.NAverage = 1;
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep = 31;
p.pfLiveMode=1;
p.tcLiveMode=0;
p.postprocessing=0;
% p.cameraParams{1}.B1BinningHorizontal = '01';
% p.cameraParams{1}.B2BinningVertical = '01';
% p.cameraParams{2}.B1BinningHorizontal = '01';
% p.cameraParams{2}.B2BinningVertical = '01';
% p.ROIWidth = 100;
% p.ROIHeight = 100;
% p.cameraParams{1}.ROI = [p.probePosInPixelfly(1)-p.ROIWidth/2,p.probePosInPixelfly(2)-p.ROIHeight/2,p.ROIWidth,p.ROIHeight];
p.cameraParams{2}.E2ExposureTime = 1e3;
% p.cameraParams{1}.E2ExposureTime = 1e3;
p.idsMonitor = 1;
initinst
initr
p.expName = 'IDS photo sequence for dipole focus tracking (AOM heating)';

%% 
p.flashTime = 150;

p.s = sqncr;
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',p.flashTime});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTopTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'pause','duration',p.flashTime+200e3});
p.s.addBlock({'forEnd','value',p.picsPerStep});
p.s.addBlock({'GenPause','duration',200e3});
p.s.run;
%%

croppedImages=r.images{2}(470:540,1000:1050,1:30);
imageViewer(croppedImages)

[fp,gof,fimages]=vec2DgaussFit(0:50,0:70,croppedImages,zeros(size(croppedImages(:,:,1))));
yCent=(540-470)/2;
xCent=(1050-1000)/2;
figure;
for ind=1:30
subplot(6,5,ind)
plot(croppedImages(xCent,:,ind))
hold on
plot(fimages(xCent,:,ind))
end

figure;
for ind=1:30
plot(croppedImages(yCent,:,ind))
hold on
end


figure;
for ind=1:30
plot(croppedImages(:,xCent,ind))
hold on
end

figure;
subplot(1,2,1)
plot(50e3*(1:(p.picsPerStep-1)),fp(3,:),'DisplayName','x')
hold on
plot(50e3*(1:(p.picsPerStep-1)),fp(4,:),'DisplayName','y')
legend
subplot(1,2,2)
plot(50e3*(1:(p.picsPerStep-1)),fp(5,:),'DisplayName','\sigma x')
hold on
plot(50e3*(1:(p.picsPerStep-1)),fp(6,:),'DisplayName','\sigma y')
legend

