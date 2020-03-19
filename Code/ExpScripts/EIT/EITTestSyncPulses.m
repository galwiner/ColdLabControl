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
p.probePower=4e-11;
loadNoise
%%
%reset mot and varify zeeman switch
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.runStep();
p.expName = 'EIT Calibration';
p.freqNum = 40;
p.NAverage = 1;
p.cyclesPerRun=20;
p.probeRampSpan = 16;
p.probeCenterOffset=-4;
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [8];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.gateNum = 10000;
p.gateTime=20;
p.biasField=-0.5; %gauss
p.loopVals{1} = linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.DTParams.MOTLoadTime = 0.25e6;
p.MagneticPulseTime=(p.gateNum) * (p.gateTime+1) + 30e3; %30mS for shutter delays
p.repumpTime=100;
% inst.BiasFieldManager.configBpulse([NaN,p.biasField,NaN],p.MagneticPulseTime);
p.DTParams.TrapTime=1;
p.MOTReloadTime = 1;
p.zeemanPumpOn=1;
p.ZeemanPumpTime = 20;
p.controlPower = 465; %in mW directly after fiber
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'pause','duration',5e3});  
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrapAndPump'});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
%measure
p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'});
p.s.addBlock({'measureSPCMWith480Control'});
p.s.addBlock({'forEnd','value',p.gateNum});
%reset
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

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=ttDumpProcessing(r.fileNames);

%% 

p.noiseRate = noiseRate;
p.bgRate = bgRate;
p.supergateNum = 50;
p.startGate = 1e3;
EIT_plot


