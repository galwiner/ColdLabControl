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

%%
p.expName = 'DipoleTrapAlignementWithAbsorption';
p.freqNum = 1;
p.gateNum = 5000;
p.probeDet=-4;
p.BiasField=0.5;
p.zeemanRepumpND=[11]; %list with values of the ND filters used in the zeeman repump for this measurement
p.probeNDList = [1,3,2];
p.ZeemanNDList = [6,8,5,4];
p.probePower=10e-11; %in mW
p.DTParams.MOTLoadTime = 0.3e6;
p.gateTime = 20;
p.ZeemanPumpTime=p.gateNum * (p.gateTime+2) + 30e3 ;
p.DTParams.TrapTime=0.2e6;
% p.DTParams.TrapTime = 1;
p.ttDumpMeasurement=1;
fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
inst.BiasFieldManager.configBpulse([NaN,p.BiasField,NaN],p.ZeemanPumpTime);
loopNum=100;
f = figure;
gca;
hold on;
for ind=1:loopNum
inst.dumpMeas=TTDump(inst.tt,fname,1e9,[1,2,3]);
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({'LoadDipoleTrap'});

p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %trapping time 
%zeeman pump
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',3,'value','high'});
p.s.addBlock({'pause','duration',3});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter. 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 

p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time

% % 

% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
% p.s.addBlock({'pause','duration',p.repumpTime});
p.s.addBlock({'TrigScope'});
%measure

p.s.addBlock({'forStart'});
%start with trap high and not gate, to let probe frequency settle
% p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',p.gateTime/2,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',p.gateTime/2});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'pause','duration',p.gateNum*p.gateTime});
%reset
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});

% p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e4});

p.s.runStep();

inst.dumpMeas.stop
binFileToMat(fname);


[folder,name,exp]=fileparts(fname);
load(fullfile(folder,[name '.mat']));
sortedPulses=sortTimeStampsByChannels(datMat);
fprintf('%d gates received\n',length(sortedPulses{1}))
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,1e6,0.5);
% plotTTRes(chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle)
chN_phot_gc{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum,:) = [];
chN_phot_gc{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum,:) = [];
chN_phot_cycles{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum) = [];
chN_phot_cycles{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum) = [];
plot(ind,phot_per_cycle,'bo')
end