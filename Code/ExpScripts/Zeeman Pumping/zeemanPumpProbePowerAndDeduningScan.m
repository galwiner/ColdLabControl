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
p.expName = 'zeeman pump probe power and deduning scan';
%%

fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
inst.tt.setTriggerLevel(1,0.5)
p.stepTime = 1;
p.freqNum = 25;
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 45;
p.probeCenterOffset=0;
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)
pause(2)
p.probeNDList = [1,3,2];
p.ZeemanNDList = [6,8,5,4];
% p.ZeemanNDList = inf;

p.gateNums = 1000;
p.loopVals{1} = ((1:p.freqNum)-1)*p.stepTime;
p.loopVars{1} = 'freqJumpPause';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.freqJumpPause=1;
% p.loopVals{1} = linspace(1e-11,1e-11,1);
% p.loopVars{1} = 'probePower';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.NAverage = 10;
p.innerLoopDelay = 1;

p.DTParams.MOTLoadTime = 400e3;
% p.DTParams.repumpLoadingPower = 0.02;
p.repumpTime = 100;
p.ZeemanPumpTime=60e3;
nPwr=1;
p.probePowerList = linspace(5e-12,5e-11,nPwr);

p.randomized_power_list=p.probePowerList(randperm(nPwr));
% p.probePowerList = []
for ii = 1:length(p.probePowerList)
fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
p.probePower = p.randomized_power_list(ii);
inst.BiasFieldManager.configBpulse([NaN,2,NaN],p.ZeemanPumpTime);
% inst.Lasers('cooling').setEventData(coolingDetToFreq(-290,8),2,3,0); %10 MHz above resonance
p.DTParams.TrapTime=1;
p.s=sqncr();
p.s.addBlock({'syncSetProbeLockFreq','freqJumpPause',p.freqJumpPause});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %trapping time 
%zeeman pump
p.s.addBlock({'TrigScope'});
% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
% p.s.addBlock({'pause','duration',p.repumpTime});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',3,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',3,'value','high'});
p.s.addBlock({'pause','duration',3});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','duration',0,'value','low'}); %zeeman shutter. 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 

% % repump
% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'pause','duration',p.repumpTime});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
% p.s.addBlock({'pause','duration',1e3});

%measure
p.s.addBlock({'forStart'});
p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'forEnd','value',p.gateNums});
%reset
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();

dump.stop
binFileToMat(fname);
fprintf('finished probe power 0.1%f out of 0.1%f\n',ii,length(p.probePowerList));
end
[folder,name,exp]=fileparts(fname);
load(fullfile(folder,[name '.mat']));
sortedPulses=sortTimeStampsByChannels(datMat);
fprintf('%d gates received\n',length(sortedPulses{1}))
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,0.5e6,0.5);
plotTTRes(chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle)
chN_phot_cycles{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum) = [];
chN_phot_cycles{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum) = [];
PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
% 
freqs=linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
figure;
plot(freqs,PhotPerCycle)
xlabel('delta [MHz]');
% ylabel('counts per gate (10 uS)');
% title(p.probePower)
