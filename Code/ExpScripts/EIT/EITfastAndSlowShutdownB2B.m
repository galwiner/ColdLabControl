clear all
global p
global r
global inst
initp
p.hasTTresults = 1;
p.ttDumpMeasurement=1;
p.hasScopResults=0;
initinst
initr
p.probePower=5e-12;
loadNoise

%%
%reset mot and varify zeeman switch
% p.DTParams.repumpLoadingPower = 0.04;
% p.DTParams.repumpLoadingPower = 10;
% p.DTParams.coolingLoadingPower = 20;
% p.DTParams.coolingLoadingDetuning = -40;
p.useIGBT=1;
p.probePower=5e-12;
inst.DDS.setFreq(1,395.2); 
p.s=sqncr();
p.s.addBlock({'Load MOT'});
% p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.runStep();
p.expName = 'EIT_fast_shutDown_b2b';
p.freqNum = 32;
p.NAverage = 3;
p.cyclesPerRun=p.freqNum;
p.probeRampSpan = 16;
p.probeCenterOffset=-4+0;
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [11];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.gateNum = 50000;
p.gateTime=20;
p.biasField=-0.5; %gauss
p.loopVals{1} = linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.DTParams.MOTLoadTime = 0.25e6;
p.preGates=1;
p.MagneticPulseTime=(p.gateNum+p.preGates) * (p.gateTime+1) + 30e3; %30mS for shutter delays
p.repumpTime=100;
% inst.BiasFieldManager.configBpulse([NaN,p.biasField,NaN],p.MagneticPulseTime);
p.DTParams.TrapTime=1;
% p.DTParams.TrapTime=2e3*20;
p.MOTReloadTime = 1;
p.zeemanPumpOn=1;
p.ZeemanPumpTime = 10;
p.controlPower = 465; %in mW directly after fiber
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ProbeSwitch,'duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'pause','duration',5e3});  
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrapAndPump'});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); 
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
p.s.addBlock({'pause','duration',10}); 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
p.s.addBlock({'pause','duration',10}); 
p.s.addBlock({'forEnd','value',p.preGates});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
%measure
p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'});

p.s.addBlock({'measureSPCMWith480Control'});

p.s.addBlock({'forEnd','value',p.gateNum});
%reset
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 

p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();
% keepDipoleTrapWarm
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);

%

% p.noiseRate = noiseRate;
% p.bgRate = bgRate;
% 
% p.supergateNum = 50;
% p.startGate = 0;
% EIT_plot
load(matFileName)
removeDoubleCycle;
fixMissingCycle
superGate = 500; 
sectionsList = {1:superGate:(p.gateNum+superGate)};
sectionByList = string('gate');
sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,p.NAverage);
plotList = sectionsList{1}(2:end-1);
EIT = (sectionedRes.phot_per_cycle/(superGate*p.gateTime/2)-noiseRate)/(bgRate-noiseRate);
% EIT = (sectionedRes.phot_per_cycle);
figure;
imagesc(plotList,p.loopVals{1},EIT)
title(sprintf('probe power = %0.2d',p.probePower))
colorbar


%% Slow phase
p.useIGBT=0;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
% p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.runStep();
p.expName = 'EIT_slow_shutDown_b2b';

p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ProbeSwitch,'duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'pause','duration',5e3});  
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrapAndPump'});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); 
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
p.s.addBlock({'pause','duration',10}); 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
p.s.addBlock({'pause','duration',10}); 
p.s.addBlock({'forEnd','value',p.preGates});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
%measure
p.s.addBlock({'TrigScope'});

p.s.addBlock({'forStart'});

p.s.addBlock({'measureSPCMWith480Control'});

p.s.addBlock({'forEnd','value',p.gateNum});
%reset
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 

p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();
% keepDipoleTrapWarm
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);

%

% p.noiseRate = noiseRate;
% p.bgRate = bgRate;
% 
% p.supergateNum = 50;
% p.startGate = 0;
% EIT_plot
load(matFileName)
removeDoubleCycle;
fixMissingCycle
superGate = 500; 
sectionsList = {1:superGate:(p.gateNum+superGate)};
sectionByList = string('gate');
sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,p.NAverage);
plotList = sectionsList{1}(2:end-1);
EIT = (sectionedRes.phot_per_cycle/(superGate*p.gateTime/2)-noiseRate)/(bgRate-noiseRate);
% EIT = (sectionedRes.phot_per_cycle);
figure;
imagesc(plotList,p.loopVals{1},EIT)
title(sprintf('probe power = %0.2d',p.probePower))
colorbar

%% blue strobe
p.useIGBT=0;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
% p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.runStep();
p.expName = 'EIT_blueStrobe_b2b';
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ProbeSwitch,'duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'pause','duration',5e3});  
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrapAndPump'});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); 
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); 
p.s.addBlock({'pause','duration',10}); 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
p.s.addBlock({'pause','duration',10}); 
p.s.addBlock({'forEnd','value',p.preGates});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
%measure
p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'});

p.s.addBlock({'measureSPCMWith480Control'});

p.s.addBlock({'forEnd','value',p.gateNum});
%reset
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 

p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();
% keepDipoleTrapWarm
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);

%

% p.noiseRate = noiseRate;
% p.bgRate = bgRate;
% 
% p.supergateNum = 50;
% p.startGate = 0;
% EIT_plot
load(matFileName)
removeDoubleCycle;
fixMissingCycle
superGate = 500; 
sectionsList = {1:superGate:(p.gateNum+superGate)};
sectionByList = string('gate');
sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,p.NAverage);
plotList = sectionsList{1}(2:end-1);
EIT = (sectionedRes.phot_per_cycle/(superGate*p.gateTime/2)-noiseRate)/(bgRate-noiseRate);
% EIT = (sectionedRes.phot_per_cycle);
figure;
imagesc(plotList,p.loopVals{1},EIT)
title(sprintf('probe power = %0.2d',p.probePower))
colorbar
keepDipoleTrapWarm
