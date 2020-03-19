

% clear all
global p
global inst
% global r
% global inst
% DEBUG=0;
% initp
% p.hasScopResults=0;
% p.hasPicturesResults = 0;
% p.ttDumpMeasurement=0;
% p.hasTTresults = 0;
% p.pfLiveMode=1;
% p.tcLiveMode=1;
% p.postprocessing=0;
% p.calcTemp=0;
% p.DEBUG=DEBUG;
% initinst
% initr
%%
origp = p;
p.expName = 'keepDipoleTrapWarm';
p.gateNum = 1e4;
p.OnePhotLineGateNum = 1e3;
p.NoiseGateNum = 0;
p.DTParams.MOTLoadTime = 0.25e6;
p.gateTime = 20;
p.MagneticPulseTime=(p.gateNum+p.NoiseGateNum+p.OnePhotLineGateNum ) * (p.gateTime+1) + 30e3 ;
p.MOTReloadTime = 1;
p.DTParams.TrapTime = 1;
p.zeemanPumpOn=1;
p.ZeemanPumpTime = 20;
p.repumpTime = 100;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3});  
p.s.addBlock({'LoadDipoleTrap_noShutter'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','low'});
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
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
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
%measure 1 photon line
p.s.addBlock({'forStart'});
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
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e3+100e3});%we add 100ms to account for the FPGA seq upload time

p.s.runStep();

inst.com.Execute(4000)
p = origp;
