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
p.ttDumpMeasurement = 1;
initinst
initr
p.looping=1;

%%
p.expName = 'ProbeRefPower';
inst.tt.setTriggerLevel(1,0.5)
p.cyclesPerRun = 10;
p.NAverage = 10;
p.gateNum = 30000;
p.probeNDList = [1,3,2];
p.probePower=5e-11;
p.gateTime = 20;
fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
p.s=sqncr();
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter closes
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
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter

p.s.addBlock({'GenPause','duration',1e6});
p.s.run();

dump.stop
binFileToMat(fname);

% loopNumsList=[length(p.loopVals{1}),length(p.loopVals{2}),p.NAverage];
% parts=sliceCycleToParts(chN_phot_cycles,chN_phot_gc,phot_per_cycle,[p.gateNum,p.gateNum+p.OnePhotLineGateNum],loopNumsList);
% sortedParts=sortRandomizedParts(parts,r);

[folder,name,exp]=fileparts(fname);
load(fullfile(folder,[name '.mat']));
% %
% 
% 
sortedPulses=sortTimeStampsByChannels(datMat);
% fprintf('%d gates received\n',length(sortedPulses{1}))
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,1e4,0.5);
PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
cycleTime = p.gateNum*p.gateTime/2;
bgRate = PhotPerCycle/cycleTime;