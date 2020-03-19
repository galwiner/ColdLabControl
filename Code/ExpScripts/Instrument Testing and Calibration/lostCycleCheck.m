
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
p.chanList = 2;
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

p.expName = 'lost cycle check';
p.BiasField=-0.05;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [8];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.probePower=1e-11; %in mW
p.gateNum=2000;
p.NAverage = 35;
p.DTParams.MOTLoadTime = 1;
p.gateTime = 20;
p.MagneticPulseTime=p.gateNum * (p.gateTime+1) + 30e3 ;
p.MOTReloadTime = 1;
p.ZeemanPumpTime = 20;
p.zeemanPumpOn=1;
% fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
% dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
inst.BiasFieldManager.configBpulse([NaN,p.BiasField,NaN],p.MagneticPulseTime);
p.DTParams.TrapTime = 1;
p.cyclesPerRun = p.NAverage;
p.s=sqncr();

p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trappcloing time
%measure
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
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
%reset
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
load(matFileName)
pks = findpeaks(diff(double(sortedPulses{1})),'MinPeakProminence',2e11);
figure;
findpeaks(diff(double(sortedPulses{1})),'MinPeakProminence',2e11)
