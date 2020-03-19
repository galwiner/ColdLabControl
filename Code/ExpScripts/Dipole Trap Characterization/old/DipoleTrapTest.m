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
p.DTPos = {[819,584],[384,565]};
p.DTWidthHight = {[200,200],[150,150]};
p.DipoleTrapROI = {[p.DTPos{1}(1)-p.DTWidthHight{1}(1)/2,p.DTPos{1}(2)-p.DTWidthHight{1}(2)/2,...
    p.DTWidthHight{1}(1),p.DTWidthHight{1}(2)]...
    [p.DTPos{2}(1)-p.DTWidthHight{2}(1)/2,p.DTPos{2}(2)-p.DTWidthHight{2}(2)/2,...
    p.DTWidthHight{2}(1),p.DTWidthHight{2}(2)]};
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep = 1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=1;
p.calcTemp = 0;
p.DTPic = 0;
p.DEBUG=DEBUG;
if p.picsPerStep == 1 ||p.picsPerStep == 2
    p.calcTemp = 0;
    p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
    p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
    %     p.cameraParams{1}.ROI = [600,400,400,360];
else
    p.calcTemp = 1;
    p.cameraParams{1}.B1BinningHorizontal = '04';
    p.cameraParams{1}.B2BinningVertical = '04';
    p.cameraParams{1}.ROI = [0,0,1392/4,1040/4];
end
p.cameraParams{1}.E2ExposureTime = 1e3;
% p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
% p.cameraParams{2}.E2ExposureTime = 50;
p.NAverage = 1;

% p.HHYCurrent = -100e-3;
% p.HHZCurrent = -30e-3;
initinst
initr
p.expName = 'Dipole Trap test';
%% 
p.MOTReloadTime = 0.5e6;
p.GaussianFitThreshold = 0.5;
p.flashTime = 50;
p.NAverage = 1;
p.DTPic = 1;
p.MOTLoadTime = 6e6;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
p.TOFtimes = [5,10,15,20]*1e3;
p.compressionRampTime = 40e3; %in us
p.PGCPower = 500;
p.PGCTime = 3e3;
p.PGCDetuning = -54;
p.CompressioncircCurrent = 80;
p.trapTime = 0.1e3;
p.compressionTime = 8e3;
p.compressionDetuning = -80;
p.repumpDetuning = 5.5;
p.CompressionPower = 1000;
p.s=sqncr();
% p.s.addBlock({'Load MOT'});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',p.repumpDetuning});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.CompressionPower});
p.s.addBlock({'setCircCurrent','channel','CircCoil','duration',0,'value',p.CompressioncircCurrent});
p.s.addBlock({'pause','duration',p.compressionRampTime});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.compressionDetuning});
p.s.addBlock({'pause','duration',p.compressionTime});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',p.trapTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
% p.s.addBlock({'endOfSeqToF'})
p.looping = int16(1);
p.s.run();
figure;
imagesc(r.images{2});hold on;plot(p.DTWidthHight{2}(1)/2,p.DTWidthHight{2}(2)/2,'xr')
figure;
imagesc(r.images{1});hold on;plot(p.DTWidthHight{1}(1)/2,p.DTWidthHight{1}(2)/2,'xr')
% disp(r.atomNum{1})



%% Old script
% % p.loopVars{1} = 'expTime';
% % p.(p.loopVars{1}) = p.INNERLOOPVAR;
% % p.loopVals{1} = linspace(30,400,10);
% % p.TOFtimes
% p.flashTime = 20;
% p.trapTime = 40e3;
% p.DTParams.MOTLoadTime = 6e6;
% p.DTParams.circCurrent = 20;
% p.DTParams.coolingDet = -4*p.consts.Gamma;
% p.s=sqncr();
% % p.s.addBlock({'setCamExp','expTime',p.expTime})
% p.s.addBlock({'LoadDipoleTrap'});
% % p.s.addBlock({'pause','duration',p.trapTime});
% % p.s.addBlock({'TakePic'});
% p.s.addBlock({'endOfSeqToF'});
% p.s.run();
% % r.images{1} = mean(r.images{1},6);
% % p.NAverage = 1;
% % p.GaussianFitThreshold = 0.3;
% % p.s.fitAll;
% % customsave;
% %
% % figure;
% % plot(p.loopVals{1},squeeze(r.atomDensity{1}));
% % imageViewer(r.images{1})
% % imageViewer(r.images{2})
% % figure;
% % yyaxis left
% % plot(p.loopVals{1},squeeze(r.atomDensity{1}))
% % yyaxis right
% % plot(p.loopVals{1},squeeze(r.atomNum{1}))
% % figure;
% % plot(p.loopVals{1},squeeze(r.fitParams{1}(5,:)))
% % hold on
% % plot(p.loopVals{1},squeeze(r.fitParams{1}(6,:)))