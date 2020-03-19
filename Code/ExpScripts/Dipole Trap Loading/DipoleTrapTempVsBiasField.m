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
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
p.cameraParams{1}.B1BinningHorizontal = '04';
p.cameraParams{1}.B2BinningVertical = '04';
p.cameraParams{1}.ROI = p.cameraParams{1}.ROI/4;
% p.cameraParams{2}.B1BinningHorizontal = '01';
% p.cameraParams{2}.B2BinningVertical = '01';
% p.DTPos{2}(1) = 525;
% p.DTWidthHight{2} = [50,200];
% p.DipoleTrapROI{2} = calculateROI(p.DTPos{2}(1),p.DTPos{2}(2),p.DTWidthHight{2}(2)...
%     ,p.DTWidthHight{2}(1));
% p.cameraParams{2}.ROI = [870,360,500,500];
% p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
% p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
p.HHXCurrent = -0.046;
p.HHYCurrent = -0.0733;
initinst
initr
p.expName = 'DipoleTrapTempVsBiasField';
%%
% p.loopVars = {};
% p.loopVals = {};
% initr
p.DTParams.repumpLoadingPower = 0.06;
p.flashTime = 300;
p.DTParams.LoadingTime = 1e5;
p.DTParams.TrapTime = 6e4;
p.NAverage = 1;
% p.HHYCurrent = -0.071;
p.scanDiraction = 'z';
switch p.scanDiraction
    case 'x'
       p.HHXCurrent = p.INNERLOOPVAR; 
    case 'y'
        p.HHYCurrent = p.INNERLOOPVAR; 
    case 'z'
        p.HHZCurrent = p.INNERLOOPVAR; 
end
p.tofTime = 8e3;
% p.tofTime = 1;
p.loopVals{1} = linspace(0.06,0.01,10);
p.HHScanVal = p.INNERLOOPVAR;
p.loopVars{1} = sprintf('HH%sCurrent',upper(p.scanDiraction));
p.s = sqncr;
p.s.addBlock({'setHH','direction',p.scanDiraction,'value',p.HHScanVal});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','low'});
p.s.addBlock({'pause','duration',5e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',2e4});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','high'});
p.s.run
% imageViewer(r.images{1})
%
meanIms = squeeze(mean(r.images{1},6));
cs = squeeze(meanIms(:,161,:));
figure;
ax = gca;
hold(ax,'on')
for ii = 1:length(p.loopVals{1})
plot((1:size(r.images{1},1))'+(ii-1)*size(r.images{1},1)*3/4,cs(:,ii))
end