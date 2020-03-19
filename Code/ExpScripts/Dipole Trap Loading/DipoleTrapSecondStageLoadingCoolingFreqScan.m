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
p.cameraParams{1}.ROI = [710-50,530-50,200,200];
p.cameraParams{2}.ROI = [980-75,450-75,300,300];

initinst
initr
p.expName = 'DipoleTrapSecondStageLoadingCoolingFreqScan';
%%
p.flashTime = 100;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
p.DTParams.LoadingTime = 1e5;
p.DTParams.TrapTime = 4e4;
% p.SecondStageTrapTime = 4e4;
p.DTParams.repumpLoadingPower = 0.0566;
p.DTParams.coolingLoadingDetuning = -20;
p.DTParams.coolingLoadingPower = 40;
% p.secondStageCoolingDet = -55;
p.secondStageCoolingPower = 10;
p.secondStageRepumpPower = 1;
p.TOFTime = 3000;
p.secondStageTime = 1e3;
p.loopVals{1} = linspace(-80,-40,1);
p.loopVars{1} = 'secondStageCoolingDet';
p.secondStageCoolingDet = p.INNERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.DTParams.repumpLoadingPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.DTParams.coolingLoadingDetuning});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.DTParams.coolingLoadingPower});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.DTParams.LoadingTime});

p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.secondStageCoolingDet});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.secondStageCoolingPower});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.secondStageRepumpPower});
p.s.addBlock({'pause','duration',p.secondStageTime})

p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setAnalogChannel','channel','CircCoil','duration',0,'value',0});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','low','duration',0});
p.s.addBlock({'pause','duration',p.DTParams.TrapTime});

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
