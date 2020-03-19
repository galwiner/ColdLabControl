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
p.tcLiveMode=0;
p.postprocessing=0;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{2}.B1BinningHorizontal = '01';
p.cameraParams{2}.B2BinningVertical = '01';
p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
p.cameraParams{1}.ROI = [710,530,100,100];
p.cameraParams{2}.ROI = [980,450,150,150];

initinst
initr
p.expName = 'DipoleTrapCoolingFreqScan';
%%
p.flashTime = 100;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
p.DTParams.LoadingTime = 1e5;
p.DTParams.TrapTime = 5e4;
p.DTParams.repumpLoadingPower = 0.0566;
% p.DTParams.coolingLoadingDetuning = -20;
p.DTParams.coolingLoadingPower = 40;
p.DepumpTime = 400;
p.TOFTime = 400;
p.loopVals{1} = linspace(-45,-15,10);
p.loopVars{1} = 'DTParams.coolingLoadingDetuning';
p.DTParams.coolingLoadingDetuning = p.INNERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','low','duration',0});
p.s.addBlock({'pause','duration',2e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.TOFTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',1e5});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','high','duration',0});
p.s.addBlock({'GenPause','duration',1e5});
p.s.run

imageViewer(r.images{2})
imageViewer(r.images{1})
