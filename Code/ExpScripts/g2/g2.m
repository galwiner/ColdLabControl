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
p.probePower=8e-11;
loadNoise

%%
p.notificationOn = 1;
%reset mot and varify zeeman switch
p.probeDet = -4.8;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.runStep();

p.expName = 'g2';
p.NAverage = 30e3;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [8];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.gateNum = 5000;
p.gateTime=20;
p.biasField=-0.5; %gauss
p.DTParams.MOTLoadTime = 0.25e6;
p.preGates=1;
p.MagneticPulseTime=(p.gateNum+p.preGates) * (p.gateTime+1) + 30e3; %30mS for shutter delays
p.DTParams.TrapTime=1;
p.MOTReloadTime = 1;
p.ZeemanPumpTime = 10;

p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ProbeSwitch,'duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'pause','duration',5e3});  
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrapAndPump'});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); 
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

keepDipoleTrapWarm;

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName,datMat]=ttDumpProcessing(r.fileNames);
% load('D:\Box Sync\Lab\ExpCold\Measurements\2019\09\23\tt\tt_230919_87__g2 measurement, with atoms, with control.mat')
% load('D:\Box Sync\Lab\ExpCold\Measurements\2019\09\23\230919_08.mat');

%%
load('D:\Box Sync\Lab\ExpCold\Measurements\2019\12\26\tt\tt_261219_750__g2.mat')
p.g2PhotPerCycle=500;
p.g2Params.Ti_pulse = 2;p.g2Params.Tf_pulse = 5.7;
p.g2Params.startGate = 30;
p.g2Params.endGate = 4860;
% p.g2Params.Ti_pulse = 6.0;p.g2Params.Tf_pulse = 10.0;
p.superGate=200;
p.plotByString='gate';
process_WIS_v1


