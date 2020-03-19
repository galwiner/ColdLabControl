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
p.hasPicturesResults = 0;
p.hasTTresults = 1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
inst.Lasers('cooling').setEventData(coolingDetToFreq(-290,8),2,3,0); %Changed to -286 for zeeman pumping (depump) - -20-266 (266 is the F=2 to F=3 split, 20 is the difference between the DPAOM and the single pass AOM frequencies)
p.looping=1; 
p.expName = 'zeeman pumping with SPCM';
%%
fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
inst.tt.setTriggerLevel(1,0.5)
p.stepTime = 1;
p.freqNum = 15;
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 45;
p.probeCenterOffset=10;
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)
pause(2)
p.probeNDList = [1,3,2];
p.ZeemanNDList = [5,7,4,8];


p.gateNums = 1000;
p.freqJumpPause = 1;
p.loopVals{1} = ((1:p.freqNum)-1)*p.stepTime;
p.loopVars{1} = 'freqJumpPause';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.loopVals{1} = [1e-11,2.5e-11,5e-11,7e-11,1e-10];
% p.loopVars{1} = 'probePower';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;

p.NAverage = 1;
p.innerLoopDelay = 1e6;
% p.loopVals{1} = linspace(1e-12,1e-10,10);
% p.loopVars{1} = 'probeDet';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.probePower = 1e-10;
p.DTParams.MOTLoadTime = 1e6;
p.DTParams.repumpLoadingPower = 0.047;
p.repumpTime = 10;
% p.DTParams.TrapTime = 1e3;
p.ZeemanPumpTime=50e3;

inst.BiasFieldManager.configBpulse([NaN,5,NaN],p.ZeemanPumpTime);
% inst.Lasers('cooling').setEventData(coolingDetToFreq(-290,8),2,3,0); %10 MHz above resonance
p.DTParams.TrapTime=1;
p.s=sqncr();
p.s.addBlock({'syncSetProbeLockFreq','freqJumpPause',p.freqJumpPause});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',20e3}); %trapping time 
%repump
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.repumpTime});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',1e3});
%zeeman pump
p.s.addBlock({'TrigScope'});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',1,'value','high'});
p.s.addBlock({'pause','duration',1});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','duration',0,'value','low'}); %zeeman shutter. 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','high','duration',0});
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 



%measure
p.s.addBlock({'forStart'});
% p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
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
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0});
p.s.addBlock({'pause','duration',5e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();

dump.stop
binFileToMat(fname);
[folder,name,exp]=fileparts(fname);
load(fullfile(folder,[name '.mat']));
sortedPulses=sortTimeStampsByChannels(datMat);
fprintf('%d gates received\n',length(sortedPulses{1}))
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,0.5e6,0.5);
%
% setFreqs = linspace((p.probeLockCenter-p.probeRampSpan/2),(p.probeLockCenter+p.probeRampSpan/2),length(p.loopVals{1}));
% 
% for ii = 1:length(p.loopVals{1})
%    photCount(ii) =  length(find(chN_phot_cycles{1}==ii))+length(find(chN_phot_cycles{2}==ii));
% end
% figure;
% plot(setFreqs,photCount);
plotTTRes(chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle)
PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
freqs=linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
%initParams/lower/upper structure: [OD,Gamma,maxVal,bias,delta0]
[f1,gof1,~,~]=fitExpLorentzian(freqs',PhotPerCycle/p.gateNums,[1,5,12,0.025,10],[0,0,10,0.05,7],[50,10,14,0.5,12],[min(freqs),max(freqs)]);
confs=confint(f1);
%%
figure;
plot(freqs,PhotPerCycle/p.gateNums)
hold on
plot(freqs,f1(freqs),'-r')
text(20,6,sprintf('OD: %.2f',abs(f1.OD)))
text(20,4,sprintf('Gamma: %.2f MHz',abs(f1.Gamma)))
xlabel('delta [MHz]');
ylabel('counts per gate (10 uS)');
title(p.probePower)

