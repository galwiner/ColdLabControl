%cooling power sweep with fast mode spectroscopy
clear all
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
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{2}.B1BinningHorizontal = '01';
p.cameraParams{2}.B2BinningVertical = '01';
% p.ROIWidth = 400;
% p.ROIHeight = 400;
% p.cameraParams{1}.ROI = [p.probePosInPixelfly(1)-p.ROIWidth/2,p.probePosInPixelfly(2)-p.ROIHeight/2,p.ROIWidth,p.ROIHeight];
% p.cameraParams{1}.ROI = [p.DTPos{1}(1)-p.ROIWidth/2,p.DTPos{1}(2)-p.ROIHeight/2,p.ROIWidth,p.ROIHeight];

p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
p.idsMonitor = 0;
initinst
initr
p.expName = 'cloude position vs DT loading time';

%% 
p.DTParams.secondStageTime = 1;
p.flashTime = 200;
p.loopVals{1} = linspace(1,1e5,20);
p.loopVars{1} = 'DTParams.LoadingTime';
p.DTParams.LoadingTime = p.INNERLOOPVAR;
p.NAverage = 1;
p.s = sqncr;
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'TakePic'});
p.s.addBlock({p.compoundActions.TakePicWithCooling});
% p.s.addBlock({'pause','duration',2e5});
p.s.addBlock({'Reload MOT'})
p.s.run
% imageViewer(r.images{2})
posOnIDS = [650, 494];
IDSWidth = 200;
idsROI = [posOnIDS(2)-IDSWidth/2,posOnIDS(2)+IDSWidth/2,posOnIDS(1)-IDSWidth/2,posOnIDS(1)+IDSWidth/2];
figure;
tiledlayout('flow')
for ii = 1:length(p.loopVals{1})
    nexttile
    imagesc(r.images{2}(idsROI(1):idsROI(2),idsROI(3):idsROI(4),ii))
    colorbar
end
