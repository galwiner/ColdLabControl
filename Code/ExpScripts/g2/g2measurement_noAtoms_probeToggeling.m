clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='g2 measurement, no atoms, probe toggeling (pulse shape measurement)';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
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
% inst.DDS.setFreq(1,341.6,0,0);
p.s = sqncr;
p.s.addBlock({'setProbeDetuning','detuning',-3.3});
p.s.runStep;
p.pauseBetweenRunSteps = 1;
p.repumpTime = 20;
p.NAverage = 5;
p.gatesPerCycle=500;
p.probeNDList=[1,3];
p.probePower=5e-10;
p.DTParams.TrapTime = 3e4;

folder=getCurrentSaveFolder();
fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
p.DTParams.MOTLoadTime = 1;
p.MOTReloadTime = 8e5;
p.gateTime=30;

p.s = sqncr;
% p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
% p.s.addBlock({'setHH','direction','x','value',0.1});
% p.s.addBlock({'startTTgatedCount','countVectorLen',p.TTbinsPerStep});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});

% p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0}); %Blue light shutter off
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0}); %Blue light AOM on
% p.s.addBlock({'pause','duration',5e3}); %shutter close delay
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
% p.s.addBlock({'LoadDipoleTrap'});
% p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','high','duration',0}); %open the shutter but switch off the blue light
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
% p.s.addBlock({'pause','duration',5e3}); %shutter open delay
%repump
% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'pause','duration',p.repumpTime});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
% p.s.addBlock({'pause','duration',1e3});
%measure
p.s.addBlock({'forStart'});

p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',10});
% p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',10});
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',p.gateTime});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',90});
p.s.addBlock({'forEnd','value',p.gatesPerCycle});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0}); %Blue AOM on but shutter off.(keeping AOM hot)
% p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e5}); 
p.s.run
dump.stop
binFileToMat(fname);
[folder,name,exp]=fileparts(fname);
load(fullfile(folder,[name '.mat']));
sortedPulses=sortTimeStampsByChannels(datMat);
fprintf('%d gates received\n',length(sortedPulses{1}))
% assert(length(sortedPulses{1})==p.NAverage*p.gatesPerCycle)
% tic
% sortedPulses = removeEarlyPhotonsRawData(sortedPulses);
% sortedPulses =removeParasiticPhotons(sortedPulses);
% toc
% tic
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,5e5,0.5);
% toc
% plot(chN_phot_time{1})
% indsToRemove1 = find(chN_phot_cycles{1}==408);
% indsToRemove2 = find(chN_phot_cycles{2}==408);
% chN_phot_cycles{1}(indsToRemove1) = [];
% chN_phot_cycles{2}(indsToRemove2) = [];
% chN_phot_gc{1}(indsToRemove1) = [];
% chN_phot_gc{2}(indsToRemove2) = [];
% chN_phot_time{1}(indsToRemove1) = [];
% chN_phot_time{2}(indsToRemove2) = [];
% chN_phot_cycles{1}(indsToRemove1) = [];
% chN_phot_cycles{2}(indsToRemove2) = [];
% chN_gates_each_cycle{1}(408) = 500;
% chN_gates_each_cycle{2}(408) = 500;
% phot_per_cycle(408) = [];
SavefileName=getNextMatFileName(getCurrentSaveFolder,'MIT_','.mat');
filename=fullfile(getCurrentSaveFolder,SavefileName);
save(filename,'chN_phot_cycles','chN_phot_gc','chN_phot_time','phot_per_cycle','chN_gates_each_cycle');
% save('tempdat.mat','chN_phot_cycles','chN_phot_gc','chN_phot_time','phot_per_cycle','chN_gates_each_cycle');


% fileparts(fullfile(getCurrentSaveFolder,SavefileName))
% filename='D:\Box Sync\Lab\ExpCold\Measurements\2019\05\20\tt\multiCycleData.mat';
% filename='D:\Box Sync\Lab\ExpCold\ControlSystem\Code\ExpScripts\tempdat.mat';
runs=max(chN_phot_cycles{1});
process_WIS_v1