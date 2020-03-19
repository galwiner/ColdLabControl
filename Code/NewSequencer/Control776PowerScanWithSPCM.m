clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
p.hasPicturesResults = 0;
p.hasTTresults = 1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
p.ttDumpMeasurement = 1;
initinst
initr
p.looping=1;

%%
p.expName = 'Control 776 power with SPCM';
inst.tt.setTriggerLevel(1,0.5)
p.probeRampSpan = 30;
p.probeCenterOffset=-3;
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
p.controlPowerSteps = 1;
p.freqNum = 15;
p.stepTime = 1;
p.probeRampTime = p.stepTime*p.freqNum;
p.NAverage = 1;
p.cyclesPerRun = 10;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [6,8,5,4];
p.probePower=5e-11;
p.gateNum = 2000;
p.OnePhotLineGateNum = 1e3;
p.NoiseGateNum = 1e3;
p.gateTime=20;
p.biasField=0.0; %gauss
p.loopVals{1} = linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.loopVals{2} = linspace(0.3,0.3,p.controlPowerSteps);
p.loopVars{2} = 'control776Power';
p.(p.loopVars{2}) = p.OUTERLOOPVAR;
p.Control776NDList = 7;
p.innerLoopDelay = 1;
p.DTParams.MOTLoadTime = 0.4e6;
p.ZeemanPumpTime=(p.gateNum+p.NoiseGateNum+p.OnePhotLineGateNum ) * (p.gateTime+1) + 30e3 ;
p.zeemanRepumpND=[10,11]; %list with values of the ND filters used in the zeeman repump for this measurement
inst.BiasFieldManager.configBpulse([NaN,p.biasField,NaN],p.ZeemanPumpTime);
p.DTParams.TrapTime=0.2e6;
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'set776ControlPower','value',p.control776Power,'duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','duration',0,'value','low'});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %trapping time 

%zeeman pump
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',3,'value','high'});
p.s.addBlock({'pause','duration',3}); %zeeman pump light on
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter closes

p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
%measure
p.s.addBlock({'forStart'});
p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','duration',0,'value','low'}); 
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.gateNum});

% measure 1 photon line
p.s.addBlock({'forStart'});
p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.OnePhotLineGateNum});
%measure noise
p.s.addBlock({'forStart'});
p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','duration',0,'value','low'}); 
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.NoiseGateNum});
%reset
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();

% dump.stop
% binFileToMat(fname);

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName,sortedPulses]=ttDumpProcessing(r.fileNames);
save('D:\Box Sync\Lab\ExpCold\Measurements\2019\07\22\tt\procesedTTdata_220719_98','chN_phot_cycles','chN_phot_gc','chN_phot_time','phot_per_cycle','chN_gates_each_cycle');

chN_phot_gc{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum*p.controlPowerSteps,:) = [];
chN_phot_gc{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum*p.controlPowerSteps,:) = [];
chN_phot_cycles{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum*p.controlPowerSteps) = [];
chN_phot_cycles{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum*p.controlPowerSteps) = [];
% 
fullChN_phot_cycles = chN_phot_cycles;
fullChN_phot_gc = chN_phot_gc;
% 
NoiseChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)>p.gateNum+p.OnePhotLineGateNum);
NoiseChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)>p.gateNum+p.OnePhotLineGateNum);
NoiseChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)>p.gateNum+p.OnePhotLineGateNum,:)-(p.gateNum+p.OnePhotLineGateNum);
NoiseChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)>p.gateNum+p.OnePhotLineGateNum,:)-(p.gateNum+p.OnePhotLineGateNum);
chN_phot_cycles = NoiseChN_phot_cycles;
chN_phot_gc = NoiseChN_phot_gc;
PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
p.noiseRate = mean(PhotPerCycle)/(p.NoiseGateNum*(p.gateTime/2));
chN_phot_cycles = fullChN_phot_cycles;
chN_phot_gc = fullChN_phot_gc;
%extract 1 photon line data data

OnePhotChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)>p.gateNum&chN_phot_gc{1}(:,2)<=p.gateNum+p.OnePhotLineGateNum);
OnePhotChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)>p.gateNum&chN_phot_gc{2}(:,2)<=p.gateNum+p.OnePhotLineGateNum);
OnePhotChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)>p.gateNum&chN_phot_gc{1}(:,2)<=p.gateNum+p.OnePhotLineGateNum,:)-p.gateNum;
OnePhotChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)>p.gateNum&chN_phot_gc{2}(:,2)<=p.gateNum+p.OnePhotLineGateNum,:)-p.gateNum;
chN_phot_cycles = OnePhotChN_phot_cycles;
chN_phot_gc = OnePhotChN_phot_gc;
[PhotPerCycle,PhotPerCycleSDT,~]=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
PhotPerCycle = reshape(PhotPerCycle,[length(p.loopVals{1}),length(p.loopVals{2})]);
PhotPerCycle = sortRandomizedResults(PhotPerCycle);
PhotPerCycle = mean(PhotPerCycle,2);
p.bgRate = max(PhotPerCycle)/(p.OnePhotLineGateNum*p.gateTime/2);
abso=(PhotPerCycle./(p.OnePhotLineGateNum*p.gateTime/2)-p.noiseRate)./(p.bgRate-p.noiseRate);
absoSD=(PhotPerCycleSDT./(p.OnePhotLineGateNum*p.gateTime/2))./p.bgRate;
% absoSD(absoSD==0)=1;
% [OD,Gamma,maxVal,bias,delta0]
initParams=[1,3,1,0,-3];
lower=[0.1,1,1,0,-10];
upper=[5,5,1,0,10];
% freqs=p.loopVals{1};
[f1phot,gof1phot,~,~]=fitExpLorentzian(freqs,abso,initParams,lower,upper,[]);
figure;
plot(freqs,abso);
hold on
plot(f1phot)
title(sprintf('OD=%.2f, Gamma_p = %.2f',f1phot.OD,f1phot.Gamma'))
chN_phot_cycles = fullChN_phot_cycles;
chN_phot_gc = fullChN_phot_gc;
p.bgRate = f1phot.maxVal*p.bgRate;
p.Gamma = f1phot.Gamma;
p.OD = f1phot.OD;
p.deltap = f1phot.delta0;
%extract only the EIT
EITChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<=p.gateNum);
EITChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<=p.gateNum);
EITChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)<=p.gateNum,:);
EITChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)<=p.gateNum,:);
chN_phot_cycles{1} = EITChN_phot_cycles{1};
chN_phot_gc{1} = EITChN_phot_gc{1};
chN_phot_cycles{2} = EITChN_phot_cycles{2};
chN_phot_gc{2} = EITChN_phot_gc{2};
% p.supergateNum = 1;
% EIT_parameterFit_plot;
[PhotPerCycle,PhotPerCycleSDT,~]=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
PhotPerCycle = reshape(PhotPerCycle,[length(p.loopVals{1}),length(p.loopVals{2})]);
PhotPerCycle = sortRandomizedResults(PhotPerCycle);
abso=(PhotPerCycle./(p.gateNum*p.gateTime/2)-p.noiseRate)./(p.bgRate-p.noiseRate);
figure;
plot(freqs,abso)