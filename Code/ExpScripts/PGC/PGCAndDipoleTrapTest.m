clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='PGC and Dipole Trap Test';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=1;
if p.picsPerStep == 1 ||p.picsPerStep == 2
    p.calcTemp = 0;
    p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
    p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
else
    p.calcTemp = 1;
    p.cameraParams{1}.B1BinningHorizontal = '04';
    p.cameraParams{1}.B2BinningVertical = '04';
    p.cameraParams{1}.ROI = [0,0,1392/4,1040/4];
end
p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{2}.E2ExposureTime=1e3;
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
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
p.TOFtimes = [5,10,15,20]*1e3;
p.PGCPower = 50;
p.PGCTime = 3e3;
p.PGCDetuning = -80;
p.repumpDetuning = 5.5;
% p.loopVars{1} = 'PGCPower';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.loopVals{1} = linspace(10,200,15);
% p.loopVars{2} = 'compressionDetuning';
% p.(p.loopVars{2}) = p.OUTERLOOPVAR;
% p.loopVals{2} = linspace(-84,-40,10);
p.trapTime = 20e3;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'})
p.s.addBlock({'pause','duration',6e3});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',p.repumpDetuning});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.PGCPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.PGCDetuning});
p.s.addBlock({'pause','duration',p.PGCTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'})
p.s.addBlock({'pause','duration',p.trapTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
% p.s.addBlock({'endOfSeqToF'})
p.looping = int16(1);
p.s.run();
%
figure;
imagesc(r.images{2});hold on;plot(p.DTWidthHight{2}(1)/2,p.DTWidthHight{2}(2)/2,'xr')
figure;
imagesc(r.images{1});hold on;plot(p.DTWidthHight{1}(1)/2,p.DTWidthHight{1}(2)/2,'xr')