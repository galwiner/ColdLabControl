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
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.circCurrent = 20;
p.DTPos{1} = [671,648];
p.DTWidthHight{1} = [200,200];
p.DipoleTrapROI{1} = [p.DTPos{1}(1)-p.DTWidthHight{1}(1)/2,p.DTPos{1}(2)-p.DTWidthHight{1}(2)/2,...
    p.DTWidthHight{1}(1),p.DTWidthHight{1}(2)];
p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
p.cameraParams{1}.E2ExposureTime = 1e3;
p.idsMonitor = 1;
initinst
initr
p.expName = 'Top imaging alignement';
%%
p.flashTime = 150;
p.DTParams.TrapTime = 1;
p.shutterDuration = 1;
p.shutterDuration = 5e3;
p.DTParams.MOTLoadTime = 2e6;
figure;
for i=1:1
p.s = sqncr;
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.shutterDuration});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',15e4});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','high'});
% p.s.addBlock({'Reload MOT'});
p.s.run
% imagesc(r.images{1})
% colorbar;
% axis equal
% axis tight
% hold on
% % plot(p.DTWidthHight{1}(1)/2,p.DTWidthHight{1}(2)/2,'rx','markersize',14)
% % plot(p.DTPos{1}(1),p.DTPos{1}(2),'rx','markersize',14)
% title('considered OK when peak value ~ 1000')
% hold off
im = squeeze(r.images{1});
[~,mi] = max(im(:));
[yind,xind] = ind2sub(size(im),mi);
plot(im(yind,:));
hold on
plot(im(:,xind));
hold off
end

