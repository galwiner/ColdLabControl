clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=0;
p.hasPicturesResults = 0;
p.hasTTresults = 1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
p.looping=1;

%%
p.DTParams.repumpLoadingPower = 0.0570;
p.DTParams.coolingLoadingPower = 55;
p.DTParams.coolingLoadingDetuning = -20;
p.expName = 'FastModeSpectroscopyWithSPCM';
r.OD=[];
p.stepTime = 200; %time in us between probe freq steps. Must be below 260
p.gateTime = 20;
p.gatesPerStep = p.stepTime/p.gateTime;
p.gateNum = 3000;
p.freqNum = ceil(p.gateNum/p.gatesPerStep); %number of freq steps is the number of gates devided by the number of gates per step
p.probeRampTime = p.stepTime*p.freqNum;
lowOD = 0;
p.probeRampSpan = 80;
if lowOD
p.DTParams.repumpLoadingPower = 0.040;
% p.DTParams.coolingLoadingPower = 20;
p.DTParams.coolingLoadingDetuning = -57;
p.probeRampSpan = 20;
end

p.probeCenterOffset=-4;
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
% resetProbeLock([-100,0])
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)

p.BiasField=-0.5;
% p.BiasField=1;
p.probeNDList = [13,3,2];
p.ZeemanNDList = [8];
% p.ZeemanNDList = [inf];
p.probePower=3e-9; %in mW6
p.DTParams.MOTLoadTime = 0.25e6;
% p.DTParams.repumpLoadingPower = 0.030;
p.MagneticPulseTime=p.gateNum * (p.gateTime+2) + 30e3 ;
p.ZeemanPumpTime = 20;
p.zeemanRepumpND=[11]; %list with values of the ND filters used in the zeeman repump for this measurement
% p.DTParams.TrapTime=1.5e6;
p.DTParams.TrapTime = 1;
p.repumpTime = 100;
p.EIT = 1;
p.ttDumpMeasurement=0;
fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));

inst.BiasFieldManager.configBpulse([NaN,p.BiasField,NaN],p.MagneticPulseTime);
loopNum=100;
% inst.DDS.setFreq(1,395.2); 
f = figure;
FigNumber =f.Number;
for ind=1:loopNum
inst.dumpMeas=TTDump(inst.tt,fname,1e9,[1,2,3]);
p.s=sqncr();
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
% p.s.addBlock({p.compoundActions.LoadDipoleTrapAndPump});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %trapping time 
%zeeman pump
% p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',p.ZeemanPumpTime,'value','high'});
p.s.addBlock({'pause','duration',p.ZeemanPumpTime});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter. 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time
% % 

p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
p.s.addBlock({'pause','duration',p.repumpTime});

%start freq scan 
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','high'});
%measure

p.s.addBlock({'forStart'});
%start with trap high and not gate, to let probe frequency settle
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',p.gateTime/2});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',p.gateTime/2});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
% p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','duration',0,'value','low'});
% 
% p.s.addBlock({'pause','duration',p.gateTime/2});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',p.gateTime/2,'value','high'}); %turn on 480 AOM 
% p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','duration',p.gateTime/2,'value','high'}); %open 480 shutter 
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',p.gateTime/2});
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',p.gateTime/2});
% p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({p.compoundActions.measureSPCMWith480Control});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'pause','duration',p.gateNum*p.gateTime});
%reset
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});

p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e4});

p.s.runStep();
t = tic;
pause(0.3)
inst.dumpMeas.stop
binFileToMat(fname);


[folder,name,exp]=fileparts(fname);
load(fullfile(folder,[name '.mat']));
sortedPulses=sortTimeStampsByChannels(datMat);
fprintf('%d gates received\n',length(sortedPulses{1}))
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,0.1e6,0.5);
% plotTTRes(chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle)
chN_phot_gc{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum,:) = [];
chN_phot_gc{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum,:) = [];
chN_phot_cycles{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum) = [];
chN_phot_cycles{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum) = [];
proceseTime = toc(t);
% fprintf('data procese time = %0.2f\n',proceseTime);
p.supergateNum = p.freqNum;
% p.supergateNum = 1;
p.plotSmooth = 10;
t1 = tic;
fastMode_Spectroscopy_plot
fitTime = toc(t1);
% fprintf('fit time = %0.2f\n',fitTime);
end
% PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);


%% 
% freqs=linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
% figure;
% if length(freqs)==length(PhotPerCycle)
%     plot(freqs,PhotPerCycle)
%     xlabel('delta [MHz]');
% else
%     plot(PhotPerCycle);
%     xlabel('Meas Number');
% end
% ylabel('counts per gate (10 uS)');
% title(sprintf('probe power = %.1e pW',1e9*p.probePower))
