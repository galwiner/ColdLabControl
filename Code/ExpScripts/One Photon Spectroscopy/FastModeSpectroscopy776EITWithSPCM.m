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
pause(4)
p.expName = 'FastModeSpectroscopy776EITWithSPCM';
r.OD=[];
inst.tt.setTriggerLevel(1,0.5)
p.stepTime = 200; %time in us between probe freq steps. Must be below 260
p.gateTime = 20;
p.gatesPerStep = p.stepTime/p.gateTime;
p.gateNum = 5000;
p.freqNum = ceil(p.gateNum/p.gatesPerStep); %number of freq steps is the number of gates devided by the number of gates per step
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 50;
p.probeCenterOffset=-4;
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)
p.Control776NDList = 7;

p.BiasField=0;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [6,8,5,4];
% p.ZeemanNDList = [inf];
p.probePower=5e-11; %in mW
p.DTParams.MOTLoadTime = 2e6;
% p.DTParams.repumpLoadingPower = 0.045;
p.ZeemanPumpTime=p.gateNum * (p.gateTime+2) + 30e3 ;
p.zeemanRepumpND=[11]; %list with values of the ND filters used in the zeeman repump for this measurement
% p.DTParams.TrapTime=0.8e6;
p.DTParams.TrapTime = 1;
p.repumpTime = 100;
p.control776Power = 1e-2;
p.EIT = 1;
p.ttDumpMeasurement=1;
fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
inst.BiasFieldManager.configBpulse([NaN,p.BiasField,NaN],p.ZeemanPumpTime);
loopNum=1;
f = figure;
FigNumber =f.Number; 
for ind=1:loopNum
inst.dumpMeas=TTDump(inst.tt,fname,1e9,[1,2,3]);
p.s=sqncr();
p.s.addBlock({'set776ControlPower','value',p.control776Power,'duration',0});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %trapping time 

%zeeman pump
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',3,'value','high'});
p.s.addBlock({'pause','duration',3});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter. 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time

%start freq scan 
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','high'});
%measure

p.s.addBlock({'forStart'});
%start with trap high and not gate, to let probe frequency settle
% p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','duration',0,'value','low'}); 
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','duration',p.gateTime/2,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',p.gateTime/2});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.gateNum});
%reset
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});

p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e4});

p.s.runStep();

inst.dumpMeas.stop
binFileToMat(fname);


[folder,name,exp]=fileparts(fname);
load(fullfile(folder,[name '.mat']));
sortedPulses=sortTimeStampsByChannels(datMat);
fprintf('%d gates received\n',length(sortedPulses{1}))
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,1e6,0.5);
% plotTTRes(chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle)
chN_phot_gc{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum,:) = [];
chN_phot_gc{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum,:) = [];
chN_phot_cycles{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum) = [];
chN_phot_cycles{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum) = [];

p.supergateNum = p.freqNum;
% p.supergateNum = 1;
p.EIT = 1;
p.plotSmooth = 10;
fastMode_Spectroscopy_plot
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