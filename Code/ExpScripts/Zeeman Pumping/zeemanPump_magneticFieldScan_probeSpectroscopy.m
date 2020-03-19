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
p.expName = 'Zeeman Pump - magnetic field scan - Probe Spectroscopy';
%%
inst.tt.setTriggerLevel(1,0.5)
p.stepTime = 1;
p.freqNum = 30;
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 100;
p.probeCenterOffset=0;
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)
pause(2)
p.probeNDList = [1,3,2];
p.ZeemanNDList = [6,8,5,4];
p.probePower=1e-11;
p.gateNum = 30000;
p.loopVals{1} = ((1:p.freqNum)-1)*p.stepTime;
p.loopVars{1} = 'freqJumpPause';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.NAverage = 1;
p.innerLoopDelay = 1;
p.DTParams.MOTLoadTime = 2e6;
p.ZeemanPumpTime=p.gateNum * 20 + 21e3 ;
p.zeemanRepumpND=[10,11]; %list with values of the ND filters used in the zeeman repump for this measurement

fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
numFieldPts=1;
for ind=1:numFieldPts
inst.BiasFieldManager.configBpulse([NaN,2,NaN],p.ZeemanPumpTime);
p.DTParams.TrapTime=1;
p.s=sqncr();
p.s.addBlock({'syncSetProbeLockFreq','freqJumpPause',p.freqJumpPause});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %trapping time 
%zeeman pump
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',3,'value','high'});
p.s.addBlock({'pause','duration',3});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter. 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
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
p.s.addBlock({'forEnd','value',p.gateNum});
%reset
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();

dump.stop
binFileToMat(fname);
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
