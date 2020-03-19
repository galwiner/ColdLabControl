clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='g2 measurement, with atoms, with control';

p.hasTTresults=1;
p.ttDumpMeasurement=1;
initinst
initr


%%
p.probePower=1e-11;
p.probeDet = -6.5;

p.s = sqncr;
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.runStep;

p.NAverage = 3000;
p.cyclesPerRun=20;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [8];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.gateNum = 10000;
p.gateTime=20;
p.biasField=-0.5; %gauss
p.DTParams.MOTLoadTime = 0.25e6;
p.MagneticPulseTime=(p.gateNum) * (p.gateTime+1) + 30e3 ;
p.repumpTime=100;
inst.BiasFieldManager.configBpulse([NaN,p.biasField,NaN],p.MagneticPulseTime);
p.DTParams.TrapTime=1;
p.MOTReloadTime = 1;
p.zeemanPumpOn=1;
p.ZeemanPumpTime = 20;
p.controlPower = 465; %in mW directly after fiber

p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'pause','duration',5e3});  
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3});
%zeeman pump
if p.zeemanPumpOn
    zeemanChanVal='high';   
else   
    p.s.addBlock({'setRepumpPower','duration',0,'value',18});
    p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
    p.s.addBlock({'pause','duration',p.repumpTime});
    zeemanChanVal='low';   
end
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',p.ZeemanPumpTime,'value',zeemanChanVal});
p.s.addBlock({'pause','duration',p.ZeemanPumpTime}); %zeeman pump light on
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter closes
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'TrigScope'});
%measure
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();
%%
keepDipoleTrapWarm;
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=ttDumpProcessing(r.fileNames);
%crop data to be from initial gate (gi) to final gate (gf);

% gi = 1;
% gf = 500;
% chN_phot_cycles{1}(chN_phot_gc{1}(:,2)>gf|chN_phot_gc{1}(:,2)<gi) = [];
% chN_phot_cycles{2}(chN_phot_gc{2}(:,2)>gf|chN_phot_gc{2}(:,2)<gi) = [];
% 
% chN_phot_time{1}(chN_phot_gc{1}(:,2)>gf|chN_phot_gc{1}(:,2)<gi,:) = [];
% chN_phot_time{2}(chN_phot_gc{2}(:,2)>gf|chN_phot_gc{2}(:,2)<gi,:) = [];
% phot_per_cycle = phot_per_cycle*(gf-gi)/p.gateNum;
% chN_phot_gc{2}(chN_phot_gc{2}(:,2)>gf|chN_phot_gc{2}(:,2)<gi,:) = [];
% chN_phot_gc{1}(chN_phot_gc{1}(:,2)>gf|chN_phot_gc{1}(:,2)<gi,:) = [];

runs=max(chN_phot_cycles{1});
process_WIS_v1
