clear -global p
global p;
global inst;

% clear -global p
%% fundamental consts
p.consts=struct();
p.consts.kb=1.3806e-23; %kboltzman
p.consts.c=299792458; %c
p.consts.amu=1.66054e-27; %AMU in Kg
p.consts.mrb=86.909180527 * p.consts.amu; %Rb87 mass
p.consts.e=1.60217662e-19; %electron charge
p.consts.rb87D1=2*pi*377.107463380e14; %D1 transition Rb87
p.consts.rb87D2=2*pi*384.2304844685e14; %D2 transition Rb87
p.consts.hbar=1.0545718e-34;%m^2*kg/s
p.consts.Gamma=6.066; %natural line width in MHz
p.consts.a0 = 5.29177e-11; %Bohr radios, in m.
p.consts.epsilon0 = 8.854e-12;%Vacuum permittivity. In F/m (or C^2/J/m)
p.consts.mub = 9.274e-24; %J/T
%% scan parameters and results strucutre

p.loopVars={};
p.loopVals={};
p.hasPicturesResults=1;
p.hasScopResults = 0;
p.hasSpecResults = 0;
p.handheldSpecRes = 0;
p.benchtopSpecRes = 0;
p.notificationOn=0;
%%scope channels to read
%on MOTSCOPE
p.chanList=[1,2,3,4];
p.FunctionGen = 0;
%% system params and constants
p.DEBUG=0;
p.postprocessing=0; %do 2d fitting and temperature extraction at the end of each run
p.calcTemp=0;
p.pfTopLiveMode = 1; %if 1 then pixelfly will not open
p.pfPlaneLiveMode = 1; %if 1 then pixelfly will not open
p.circCurrent=20; %in A
p.pauseBetweenRunSteps=0.5; %seconds
p.looping=int16(1); %param to set multiple runs. needs to be int16 because it's fed into the FPGA code
% p.TOFtimes=[0.3e3,0.3e3,0.1e3];
p.TOFtimes=[1e3,3e3,5e3,10e3];
p.NTOF=length(p.TOFtimes);
p.picsPerStep=1;
p.NAverage = 1;
p.INNERLOOPVAR=51506678; %MAGIC NUMBERS TO SIGNIFY A VALUE TO SCAN
p.OUTERLOOPVAR=70071834; %MAGIC NUMBERS TO SIGNIFY A VALUE TO SCAN
p.MOTLoadTime = 2e6;
p.MOTReloadTime = 1.5e5;
p.coolingPower=690; % in mW
p.repumpPower=18; % in mW
p.probePower=100e-6; %in mW
p.probeNDList=[]; %numbered and calibrated NDs 13/2/19
% p.repumpPower=100;
p.coolingDet=-4*p.consts.Gamma;
p.repumpDet=0;
p.coolingLockDet = -3*p.consts.Gamma; %The locking detuning. This is set and unchanged, as of 09/10/18.
p.coolingLockFreq = coolingDetToFreq(p.coolingLockDet,8); %the locking frequency of the cooling laser. differnt than cooling det as of 09/10/18
p.cg=CodeGenerator();
p.imagingPower = 35; %in uW
p.zShutter=1; %cooling beam z shutter
%%
load('channelTable.mat');
load('plottingTable.mat');
p.ct=channelTable;
p.pt=plottingTable;
load('actionsMap.mat');
p.actionsMap=actionsMap;
p.MOTReleaseTime = 20;
p.rampStepSize=[]; %vector that is populated by all ramp step sizes (if there is more than 1 analog ramp)
p.rampTime=[];%vector that is populated by all ramp times in uS (1 if there is just 1 analog ramp)
pfparams=struct();
pfparams.timeout=100;
pfparams.B1BinningHorizontal='01';
pfparams.B2BinningVertical='01';
pfparams.E1ExposureTime_unit = 'us';
pfparams.E2ExposureTime = 100;
pfparams.TriggerRepeat=inf; %440 is the maximum size allocable when binning is 1X1.
pfparams.ROI = [0,0,1392,1040];
p.AbsImgTime=100; %absorption imaging exposure time
p.DTPic = 0;
p.cameraParams{1}=pfparams; %Pixelfle plane
p.cameraParams{2}=pfparams;%Pixelfle top
% p.HHYCurrent=-0.067439005423097;%in A
p.DTPos = {[844,579],[525,505]};
p.DTWidthHight = {[200,200],[150,70]};
p.DipoleTrapROI = {[p.DTPos{1}(1)-p.DTWidthHight{1}(1)/2,p.DTPos{1}(2)-p.DTWidthHight{1}(2)/2,...
    p.DTWidthHight{1}(1),p.DTWidthHight{1}(2)]...
    [p.DTPos{2}(1)-p.DTWidthHight{2}(1)/2,p.DTPos{2}(2)-p.DTWidthHight{2}(2)/2,...
    p.DTWidthHight{2}(1),p.DTWidthHight{2}(2)]};
p.HHXCurrent = -0.0369;
p.HHZCurrent = 0.0432;
p.HHYCurrent = -0.0744;
p.HHXVoltageLimit=20;
p.HHYVoltageLimit=20;
p.HHZVoltageLimit=20;
p.IGBTDelay = 10;
p.s=sqncr(); %the experimental sequence is saved in this field.
%spectrum Analyzer parameters
p.spectrumAnaParams = {'',''};
p.spectrumAnaParams{1} = struct('centerFreq',100,'span',20,'BW',1e5,'NAverages',1,'refAmp',0);
p.spectrumAnaParams{2} = struct('centerFreq',100,'span',20,'BW',1e5,'NAverages',1,'refAmp',0);
%postprocessing params
p.GaussianFitThreshold=0.7;
%Ploting parameters
p.plotingParams.NSubPlots = [];
p.plotingParams.SupTitle = [];
p.plotingParams.titles = [];
p.plotingParams.xlabel = [];
p.plotingParams.ylabels = [];
p.plotingParams.xaxis = [];
p.plotingParams.yaxes = [];
p.plotingParams.yyaxis = [];
p.plotingParams.legends = [];
p.plotingParams.MaximizedWindow = [];
p.absImg = {0,0}; %This is a flag for absorption image.
p.flashPower = 690; %the cooling power at imaging
%scope parameters
p.numOfScopPoints = 100000;
%% DipoleTrapParams
p.DTParams.coolingDet = -4*p.consts.Gamma;
p.DTParams.circCurrent = 20;
p.DTParams.MOTLoadTime = 2e6;
p.DTParams.DTPic = 1;
% p.DTParams.compressionRampTime = 40e3;
% p.DTParams.CompressioncircCurrent = 220;
% p.DTParams.compressionTime = 3e3;
% p.DTParams.compressionDetuning = -55;
% p.DTParams.CompressionPower = 200;
p.DTParams.repumpLoadingDetuning = 0;
p.DTParams.repumpLoadingPower = 0.1;
p.DTParams.coolingLoadingDetuning = -20;
p.DTParams.coolingLoadingPower = 30;
p.DTParams.LoadingTime = 50e3;
p.DTParams.TrapTime = 30e3;
%%
p.circLEMcalibration= 24.93e-3; %circular coils LEM V/A. note there's a 2A offset (see 9/1/2019 results)
