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
p.consts.Gamma=6.066; %natural line width in MHz. D2 F=2->F=3.
p.consts.a0 = 5.29177e-11; %Bohr radios, in m.
p.consts.epsilon0 = 8.854e-12;%Vacuum permittivity. In F/m (or C^2/J/m)
p.consts.mub = 9.274e-24; %J/T

%% scan parameters and results strucutre

p.loopVars={};
p.loopVals={};
p.randomizeLoopVals=0;
p.hasPicturesResults=0;
p.hasScopResults = 0;
p.hasSpecResults = 0;
p.handheldSpecRes = 0;
p.benchtopSpecRes = 0;
p.hasTTresults=0;
p.loopingRun=0;%if 1, this meens that customsave will not run, BIASPSU will not be configed each sqncr.run
p.run_loop_ctr = 0; %loop counter for loopig runs.
%%scope channels to read
%on MOTSCOPE
p.chanList=[1,2,3,4];
p.trigPulseTime = 1;
p.FunctionGen = 0;
%% system params and constants
p.DEBUG=0;
p.runAutoPlot=0;
p.postprocessing=0; %do 2d fitting and temperature extraction at the end of each run
p.absImagePostproc=0;
p.calcTemp=0;
p.pfLiveMode = 1; %if 1 then pixelfly will not open
p.idsLiveMode = 1; %if 1 then pixelfly will not open
p.idsMonitor = 0; %this is a flag fot the IDS camera used. 1 is for the monitor camera (i.e the one which is inline with the probe) 0 is for the plane
p.circCurrent=20; %in A
p.pauseBetweenRunSteps=0.01; %seconds
p.resetSysGenPause=300e3;
p.looping=int16(1); %param to set multiple runs. needs to be int16 because it's fed into the FPGA code
% p.TOFtimes=[0.3e3,0.3e3,0.1e3];
p.TOFtimes=[1e3,3e3,5e3,10e3];
p.NTOF=length(p.TOFtimes);
p.picsPerStep=1;
p.NAverage = 1;
p.INNERLOOPVAR=51506678; %MAGIC NUMBERS TO SIGNIFY A VALUE TO SCAN
p.OUTERLOOPVAR=70071834; %MAGIC NUMBERS TO SIGNIFY A VALUE TO SCAN
p.MOTLoadTime = 0.25e6;
p.MOTReloadTime = 1.5e5;
p.coolingPower=690; % in mW
p.repumpPower=18; % in mW
p.probePower=100e-6; %in mW
p.probeNDList=[13,2,3]; %numbered and calibrated NDs 13/2/19
p.probePosInPixelfly = [668,664]; %in pixels, [x,y]
p.probePosInMonitor = [730,395]; %in pixels, [x,y]
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
for ii = 1:length(p.ct.Row)
   p.chanNames.(p.ct.Row{ii}) = p.ct.Row{ii};
end
p.pt=plottingTable;
load('actionsMap.mat');
p.actionsMap=actionsMap;
p.MOTReleaseTime = 20;
p.rampStepSize=[]; %vector that is populated by all ramp step sizes (if there is more than 1 analog ramp)
p.rampTime=[];%vector that is populated by all ramp times in uS (1 if there is just 1 analog ramp)
pfparams=struct();
pfparams.timeout=3;
pfparams.B1BinningHorizontal='01';
pfparams.B2BinningVertical='01';
pfparams.E1ExposureTime_unit = 'us';
pfparams.E2ExposureTime = 100;
pfparams.TriggerRepeat=inf; %440 is the maximum size allocable when binning is 1X1.
pfparams.ROI = [0,0,1392,1040];
p.AbsImgTime=100; %absorption imaging exposure time
p.pixelflyScale = 4.0994e-06;
p.DTPic = 0;
p.cameraParams{1}=pfparams; %Pixelfle plane
p.cameraParams{2}=pfparams;%Pixelfle top
% p.HHYCurrent=-0.067439005423097;%in A
p.DTPos = {[683,651],[716,549]}; %[x,y]
p.DTWidthHight = {[200,200],[150,70]};
p.DipoleTrapROI = {[p.DTPos{1}(1)-p.DTWidthHight{1}(1)/2,p.DTPos{1}(2)-p.DTWidthHight{1}(2)/2,...
    p.DTWidthHight{1}(1),p.DTWidthHight{1}(2)]...
    [p.DTPos{2}(1)-p.DTWidthHight{2}(1)/2,p.DTPos{2}(2)-p.DTWidthHight{2}(2)/2,...
    p.DTWidthHight{2}(1),p.DTWidthHight{2}(2)]};
% p.HHXCurrent = -0.0369;
% p.HHZCurrent = 0.0432;
% p.HHYCurrent = -0.0744;

p.HHYCurrent = -0.085; %changed from -0.0744 on 26/01/20 by measuring OD vs current at low loading time
p.HHGaussPerAmp=[4.355,8.496,12.097]; %[x,y,z] in Gauss/A %bias coils slopes (found in File is: D:\Box Sync\Lab\ExpCold\Lab log\Bias coils\bias coil field measurements.xls)
p.B0 = [-0.1613,-0.6323,0.5231];%these are the field values that zero the magnetic field. Gathered from MW pectroscopy (see measurments on 26/08/2018)
p.xJumpBField = p.B0(1);
p.yJumpBField = p.B0(2);
p.zJumpBField = p.B0(3);
p.BiasField=-1+p.B0(2);
%Optimal values measured on 12/05/19 using MW spectrosc
p.HHZCurrent = 0.035; %vhanged from 0.04  on 26/01/20 by measuring OD vs current at low loading time
p.zBiasLocationPSU = '2,1'; %this means that the z bias coils are driven by BiasPSU2 channel 1. Another option is 1,2.
% p.HHXCurrent = -0.035;
p.HHXCurrent = -0.041;% changed from -0.035 on 26/01/20 by measuring OD vs current at low loading time
p.HHXVoltageLimit=20;
p.HHYVoltageLimit=20;
p.HHZVoltageLimit=100;
p.IGBTDelay = 10;
p.s=sqncr(); %the experimental sequence is saved in this field.
%spectrum Analyzer parameters
p.spectrumAnaParams = {'',''};
p.spectrumAnaParams{1} = struct('centerFreq',100,'span',20,'BW',1e5,'NAverages',1,'refAmp',0);
p.spectrumAnaParams{2} = struct('centerFreq',100,'span',20,'BW',1e5,'NAverages',1,'refAmp',0);
%postprocessing params
p.GaussianFitThreshold=0.7;
p.absoImageCenter=[93,92];
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
%% zeeman pumping params
p.zeemanDetuning=0;
p.zeemanRepumpDetuning = 0;
p.ZeemanNDList = [11];
p.zeemanRepumpND=[7];
p.zeemanPumpPower=0.0027; %was measured on 03/02/2020 to be a good value
p.zeemanRepumpPower=0.0056;%was measured on 03/02/2020 to be a good value
p.ZeemanPumpCycles = 20;%was measured on 03/02/2020 to be a good value
%% DipoleTrapParams
p.DTParams.coolingDet = -4*p.consts.Gamma;
p.DTParams.circCurrent = 20;
p.useIGBT=1;
p.DTParams.MOTLoadTime = 0.25e6;
p.DTParams.DTPic = 1;
% p.DTParams.compressionRampTime = 40e3;
% p.DTParams.CompressioncircCurrent = 220;
% p.DTParams.compressionTime = 3e3;
% p.DTParams.compressionDetuning = -55;
% p.DTParams.CompressionPower = 200;
p.DTParams.repumpLoadingDetuning = 0;
p.DTParams.repumpLoadingPower = 0.057;
p.DTParams.coolingLoadingDetuning = -30;% changed from -20 to -30 on 19.01.20 after measurements done in the week before
p.DTParams.coolingLoadingPower = 55;
p.DTParams.LoadingTime = 1e5;
p.DTParams.TrapTime = 1;
p.DTParams.secondStageCoolingDet = -70;
p.DTParams.secondStageCoolingPower = 280;
p.DTParams.secondStageRepumpPower = 0.042;
p.DTParams.secondStageTime = 45e3;
%%
p.circLEMcalibration= 24.93e-3; %circular coils LEM V/A. note there's a 2A offset (see 9/1/2019 results)
p.mwSource = 0;

%% time tagger params
p.ttDumpMeasurement=0;
p.cyclesPerRun=50;
%%logging file
p.logFileName=[getCurrentSaveFolder '\..\seqLog.csv'];
p.logFile=fopen(p.logFileName,'a');
%% setup commend lists
b = Block;
for ii = 1:length(b.atomic)
   p.atomicActions.(erase(b.atomic{ii},' ')) = b.atomic{ii};
end
for ii = 1:length(b.compound)
   p.compoundActions.(erase(b.compound{ii},' ')) = b.compound{ii};
end
for ii = 1:length(b.async)
   p.asyncActions.(erase(b.async{ii},' ')) = b.async{ii};
end
p.biasE = 1; %enable the bias electric field manager.
%% g2 params 

p.g2PhotPerCycle = 19000;

p.superGate=200; %for plotting phot per gate
p.plotByString='gate';
p.g2Params.isplotSupGate = 0;
p.g2Params.Ti_pulse = 0.1;
p.g2Params.Tf_pulse = 9.9;
%% AOM and digital channel delays, in mus
p.ttGateDelay = 0.45;
p.DTDelay = 0.37;
p.probeDelay = 0.5;
p.controlDelay = 1.27;
%% lasers
p.Sprout = 1;

%% notification mechanism

p.notificationOn=0;
p.notificationRecipients={'gal.winer@weizmann.ac.il','lee.drori@weizmann.ac.il'};
setpref('Internet','SMTP_Server','doar.weizmann.ac.il')
setpref('Internet','E_mail','coldLab');
% sendmail('gal.winer@weizmann.ac.il','Hello From MATLAB!')

%% system settle param
p.runSettlingLoop = 1;
p.settlingStepN=3;
%% cycle time
p.cycleTimes = "";
p.ttStartTime = [];
%%find TTGate channel number in PulseChannelInfo. This is needed to fix missing and double cycles (see seqUpload)
pulseChanData = PulseChannelInfo;
for ii = 1:length(pulseChanData)
    if strcmp(pulseChanData{ii}.ChannelName,p.ct.PhysicalName{p.chanNames.TTGate})
       p.TTGateChanNum = ii;
       break
    end
end
p.TTGateStartTimes = [];
p.runFixCycles = 1;
%% synthHD
p.synthHD = 1;
%% blue killer params
% p.Blue_Killer_I = [0.030   -0.0895    0.090];
p.Blue_Killer_I = [0.045   -0.0850    0.105]; %measured on 19/03/20
%% kdc (motorized waveplate)
p.kdcSN = 27253161;
p.kdc = 0; %if 1, use kdc controller in initinst;
