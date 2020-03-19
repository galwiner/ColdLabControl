clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=0;
p.calcTemp=0;
p.cameraParams{1}.B1BinningHorizontal = '04';
p.cameraParams{1}.B2BinningVertical = '04';
p.cameraParams{2}.B1BinningHorizontal = '04';
p.cameraParams{2}.B2BinningVertical = '04';
p.cameraParams{2}.ROI = round(p.cameraParams{2}.ROI/4);
% p.cameraParams{1}.ROI  =round(p.cameraParams{1}.ROI/4);
p.cameraParams{1}.ROI  =[190,130,40,40];
p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{2}.E2ExposureTime=1e3;
p.DEBUG=DEBUG;
initinst
initr

p.looping=1;
p.expName = 'DipoleTrapTimeOfFlightWithPic';
%%
p.repumpTime = 1;
p.MOTReleaseTime = 300;
p.flashTime = 200;
% p.DTParams.TrapTime = 2.5e4;
p.TOFTime = 1;
% p.DTParams.repumpLoadingPower = 0.057;
% p.DTParams.coolingLoadingPower = 40;
% p.DTParams.coolingLoadingDetuning = -40;
% p.DTParams.LoadingTime =  15e4;
p.NAverage = 1;
% p.DTParams.LoadingTime = 1e5;
% p.DTParams.TrapTime = 2e4;
% p.DTParams.repumpLoadingPower = 0.057;
% p.DTParams.coolingLoadingPower = 30;
% p.DTParams.coolingLoadingDetuning = -20;
p.DTParams.LoadingTime = 1e5;
p.DTParams.TrapTime = 4e4;
p.DTParams.repumpLoadingPower = 0.044;
p.DTParams.coolingLoadingPower = 55;
p.DTParams.coolingLoadingDetuning = -20;
p.DTParams.LoadingTime =  100e3;
p.trigPulseTime = 10;
p.secondStageTime = 20e3;
p.secondStageCoolingDet = -65;
p.secondStageCoolingPower = 350;
p.tofTime = 2e3;
% p.loopVars{1} = 'tofTime';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.loopVals{1} = linspace(40,1000,15);
p.trigPulseTime = 10;
p.depumpTime = 700;

% p.secondStageCoolingDet = -35;
% p.secondStageCoolingPower = 80;
p.secondStageRepumpPower = 0.05;
p.secondStageTime = 20e3;
% p.secondStageTime = 1;
%
p.s=sqncr();
% %load dipole trap
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
% p.s.addBlock({'LoadDipoleTrap'});
% %perform tof
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'pause','duration',p.tofTime});
% %measure absorption
% p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'TrigScope'});
% p.s.addBlock({'pause','duration',20});
% p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
% p.s.addBlock({'pause','duration',p.probeRampTime});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.depumpTime,'value','high'});
% p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
% p.s.addBlock({'setCoolingPower','duration',0,'value',690});
% p.s.addBlock({'pause','duration',p.depumpTime});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
% p.s.addBlock({'pause','duration',20});
% p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
% p.s.addBlock({'pause','duration',p.probeRampTime});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
% p.s.addBlock({'GenPause','duration',1e6});

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
p.s.addBlock({'pause','duration',p.DTParams.TrapTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'endOfSeqToF'});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'TakePic'});
% p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
% p.s.addBlock({'pause','duration',10});
% p.s.addBlock({'TrigScope'});
% p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
% p.s.addBlock({'pause','duration',p.probeRampTime});
% p.s.addBlock({'setCoolingDetuning','duration',0,'value',3});
% p.s.addBlock({'setCoolingPower','duration',0,'value',690});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
% p.s.addBlock({'pause','duration',p.depumpTime});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
% p.s.addBlock({'pause','duration',10});
% p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();
%
imageViewer(r.images{1})