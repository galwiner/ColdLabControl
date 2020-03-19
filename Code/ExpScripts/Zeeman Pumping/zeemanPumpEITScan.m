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
p.ttDumpMeasurement=1;
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
p.expName = 'Zeeman Pump EIT scan';
inst.tt.setTriggerLevel(1,0.5)
p.stepTime = 1;
p.freqNum = 55;
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 40;
p.probeCenterOffset=-5;
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
% p.DTParams.repumpLoadingPower = 0.035;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [8];
p.zeemanRepumpND=[10];
p.probePower=1e-10;
p.gateNum = 2000;
p.gateTime=20;
p.biasField=-0.2; %gauss
p.ZeemanPumpTime = 20;
p.MagneticPulseTime=p.gateNum * (p.gateTime+1) + 30e3 ;
p.loopVals{1} = linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.NAverage = 1;
p.innerLoopDelay = 1;
p.DTParams.MOTLoadTime = 1e6;
p.zeemanRepumpND=[10,11]; %list with values of the ND filters used in the zeeman repump for this measurement
p.repumpTime=100;
inst.BiasFieldManager.configBpulse([NaN,p.biasField,NaN],p.MagneticPulseTime);
p.DTParams.TrapTime=1;
p.s=sqncr();
% p.s.addBlock({'syncSetProbeLockFreq','freqJumpPause',p.freqJumpPause});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %trapping time 

%zeeman pump
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',p.ZeemanPumpTime,'value','high'});
p.s.addBlock({'pause','duration',p.ZeemanPumpTime}); %zeeman pump light on
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter closes
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 

% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
% p.s.addBlock({'pause','duration',p.repumpTime});


p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 

%measure
p.s.addBlock({'forStart'});
p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.gateNum});
%reset
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
load(matFileName)


loadNoise
cycleTime = p.gateNum*p.gateTime/2;
abso= (phot_per_cycle/cycleTime-p.noiseRate)/(p.bgRate-p.noiseRate);
figure;
plot(p.loopVals{1},abso)
title('n=70 EIT with Zeeman Pumping')
xlabel('detuning [MHz]')
ylabel('T')
% plotTTRes
% chN_phot_gc{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum,:) = [];
% chN_phot_gc{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum,:) = [];
% chN_phot_cycles{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum) = [];
% chN_phot_cycles{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum) = [];
% 
% gmax = 500;
% gmin = 1;
% tmpchN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)>=gmin&chN_phot_gc{1}(:,2)<=gmax);
% tmpchN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)>=gmin&chN_phot_gc{2}(:,2)<=gmax);
% p.supergateNum = 25;
% sectioned_Spectroscopy_plot;
% % PhotPerCycle=removeBadCyclesandMean(tmpchN_phot_cycles,p.NAverage);
% % % 
% % freqs=linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
% % figure;
% % plot(PhotPerCycle)
% % xlabel('delta [MHz]');
% % % ylabel('counts per gate (10 uS)');
% % title(p.probePower)