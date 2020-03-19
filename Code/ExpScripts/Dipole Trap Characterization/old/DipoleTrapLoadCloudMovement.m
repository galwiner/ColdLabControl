%cooling power sweep with fast mode spectroscopy
clear all
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
p.postprocessing=1;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{2}.B1BinningHorizontal = '01';
p.cameraParams{2}.B2BinningVertical = '01';
% p.cameraParams{2}.ROI = [890,420,390,300];
% p.cameraParams{1}.ROI = [560,390,420,350];
p.DTWidthHight{2} = [300,600];
p.DipoleTrapROI{2} = calculateROI(p.DTPos{2}(1),p.DTPos{2}(2),p.DTWidthHight{2}(2)...
    ,p.DTWidthHight{2}(1));
p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
initinst
initr
p.expName = 'Dipole Trap Load Cloud Movement';
%%
% p.loopVars = {};
% p.loopVals = {};
% initr
p.flashTime = 100;
p.DTParams.coolingLoadingPower = 10;
p.DTParams.repumpLoadingPower = 0.1;
p.loopVars{1} = 'DTParams.LoadingTime';
p.DTParams.LoadingTime = p.INNERLOOPVAR;
p.loopVals{1} = linspace(1e3,3e4,10);
p.DTParams.TrapTime = 1;
p.s = sqncr;
p.s.addBlock({'LoadDipoleTrap'});
% p.s.addBlock({'Load MOT'});
p.s.addBlock({'TakePic'});
p.s.run
% figure;
% subplot(1,2,1)
% imagesc(squeeze(r.images{1}))
% colorbar
% subplot(1,2,2)
% imagesc(squeeze(r.images{2}))
% colorbar
imageViewer(r.images{1});
imageViewer(r.images{2});
% hold on
% plot(motPos(1),motPos(2),'xr')