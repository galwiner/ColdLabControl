clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='Probe Absorption Sanity Check';
p.hasScopResults=0;
p.hasPicturesResults=0;
p.hasTTresults=1;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr
inst.tt.setTriggerLevel(1,0.5)
%%
p.pauseBetweenRunSteps = 1;
p.messTime = 100;
p.repumpTime = 20;
p.NAverage = 1;
p.gateNum=1000;
p.probeNDList=[1,3,2];
p.probePower=1e-11;
p.notificationOn=0;
p.DTParams.TrapTime = 3e5;
p.loopVals{1} = linspace(-20,20,25);
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
folder=getCurrentSaveFolder();
fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
p.DTParams.MOTLoadTime = 5e5;
p.DTParams.TrapTime = 4e4-5e3;
p.MOTReloadTime = 3e5;
p.s = sqncr;
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','value','low','duration',0}); %Blue light shutter off
p.s.addBlock({'pause','duration',5e3}); %shutter close delay
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','value','high','duration',0});
p.s.addBlock({'pause','duration',5e3});

%repump
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.repumpTime});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',1e3});
%measure
p.s.addBlock({'forStart'});
p.s.addBlock({'pause','duration',1/40});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',10});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',10});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','value','low','duration',0});
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e4}); 
p.s.run
dump.stop
binFileToMat(fname);
[folder,name,exp]=fileparts(fname);
load(fullfile(folder,[name '.mat']));
sorted=sortTimeStampsByChannels(datMat);
sortedPulses=sortTimeStampsByChannels(datMat);
fprintf('%d gates received\n',length(sortedPulses{1}))
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,0.5e6,0.5);
% plotTTRes(chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle)
PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
% PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,1);
% 
figure;
plot(linspace(p.loopVals{1}(1),p.loopVals{1}(end),length(PhotPerCycle)),PhotPerCycle)
% plot(PhotPerCycle);
xlabel('delta [MHz]');