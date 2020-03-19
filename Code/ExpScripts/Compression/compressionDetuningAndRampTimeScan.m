clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Compression Dinamics';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=1;
if p.picsPerStep == 1 ||p.picsPerStep == 2
    p.calcTemp = 0;
%     p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
%     p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
    p.cameraParams{1}.ROI = [600,400,500,400];
    p.cameraParams{2}.ROI = [250,400,250,350];
    %     p.cameraParams{1}.ROI = [600,400,400,360];
else
    p.calcTemp = 1;
    p.cameraParams{1}.B1BinningHorizontal = '04';
    p.cameraParams{1}.B2BinningVertical = '04';
    p.cameraParams{1}.ROI = [0,0,1392/4,1040/4];
end

p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{2}.E2ExposureTime=1e3;
% p.cameraParams{1}.ROI = [0,0,1392/4,1040/4];
% p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
p.DEBUG=DEBUG;
%
initinst
initr


%%
p.MOTReloadTime = 1.5e6;
p.GaussianFitThreshold = 0.5;
p.flashTime = 50;
p.NAverage = 1;
p.DTPic = 0;
p.MOTLoadTime = 4e6;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
p.TOFtimes = [5,10,15,20]*1e3;
% p.compressionRampTime = 40e3; %in us
% p.PGCPower = 500;
% p.PGCTime = 3e3;
% p.PGCDetuning = -54;
p.CompressioncircCurrent = 220;
% p.expTime = 1500;
p.loopVars{1} = 'compressionRampTime';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.loopVals{1} = linspace(500,3e3,10);
p.loopVars{2} = 'compressionDetuning';
p.(p.loopVars{2}) = p.OUTERLOOPVAR;
p.loopVals{2} = linspace(-25,-5,5);
p.trapTime = 20e3;
p.compressionTime = 1;
% p.compressionDetuning = -40;
% p.repumpDetuning = 5.5;
p.CompressionPower = 690;
p.DTLoadTime = 15e3;
p.PGCTime = 100;
p.PGCPower = 100;
p.PGCDetuning = -60;
p.s=sqncr();
p.s.addBlock({'setCircCurrent','channel','CircCoil','duration',0,'value',p.CompressioncircCurrent});
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.compressionDetuning});
p.s.addBlock({'pause','duration',p.compressionRampTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
p.looping = int16(1);
p.s.run();
%%
% imageViewer(r.images{1});
figure;
subplot(2,1,1)
plot(p.loopVals{1},squeeze(r.atomDensity{1}))
subplot(2,1,2)
plot(p.loopVals{1},squeeze(r.atomNum{1}))
legend(string(p.loopVals{2}))
% figure;
% plot(p.loopVals{1},squeeze(r.fitParams{1}(5,:)))
% hold on
% plot(p.loopVals{1},squeeze(r.fitParams{1}(6,:)))
% figure;
% imagesc(r.images{2});hold on;plot(p.DTWidthHight{2}(1)/2,p.DTWidthHight{2}(2)/2,'xr')
% figure;
% imagesc(r.images{1});hold on;plot(p.DTWidthHight{1}(1)/2,p.DTWidthHight{1}(2)/2,'xr')
% figure;
% imagesc(r.images{2});hold on;plot(p.DTPos{2}(1),p.DTPos{2}(2),'xr')
% figure;
% imagesc(r.images{1});hold on;plot(p.DTPos{1}(1),p.DTPos{1}(2),'xr')