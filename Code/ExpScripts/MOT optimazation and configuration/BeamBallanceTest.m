clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Beam Balance Test';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
if p.picsPerStep == 1 ||p.picsPerStep == 2
    p.calcTemp = 0;
%     p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
%     p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
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
p.MOTReloadTime = 2e6;
p.GaussianFitThreshold = 0.5;
p.flashTime = 100;
p.NAverage = 1;
p.DTPic = 1;
p.MOTLoadTime = 6e6;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
p.TOFtimes = [5,10,15,20]*1e3;
p.compressionRampTime = 40e3; %in us
p.CompressioncircCurrent = 80;
p.trapTime = 20e3;
p.compressionTime = 20e3;
p.compressionDetuning = -80;
p.repumpDetuning = 5.5;
p.CompressionPower = 50;
p.DTLoadTime = 15e3;
p.PGCTime = 100;
p.PGCPower = 100;
p.PGCDetuning = -60;
p.s=sqncr();
% p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'})
p.s.addBlock({'pause','duration',6e3});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.CompressionPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.compressionDetuning});
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',1000});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'pause','duration',5});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'})
p.s.addBlock({'pause','duration',15e3});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
% p.s.addBlock({'endOfSeqToF'})
p.looping = int16(1);
p.s.run();
%
imageViewer(r.images{1});