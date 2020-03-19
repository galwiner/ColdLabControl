%
clear all
global p

global r
global inst
global g2serverApp
DEBUG=0;
initp
g2serverApp=[];
p.hasScopResults=0;
p.hasPicturesResults=0;
p.picsPerStep = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.NAverage = 5;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
p.g2measurement=0;
initinst
initr
p.expName = 'g2 measurement, no atoms';
p.gateTime=10;
p.gatesPerCycle=100;
p.gateDelay=20;
p.TimeBetweenCycles=1e5;
p.probeNDList=[1,3];
tt=TimeTagger;
tt.setTriggerLevel(1,0.5)    
p.pauseBetweenRunSteps=0.1;
%% 
% g2serverApp.toggleMeas(1)
p.loopVars = {'probePower'};
probePowerVals=5e-10+rand(1,100)*2e-10;
p.loopVals={probePowerVals};
p.(p.loopVars{1})=p.INNERLOOPVAR;

folder=getCurrentSaveFolder();
fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
dump=TTDump(tt,fname,1e9,[1,2,3]);
p.s=sqncr();
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',1e4});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime});
p.s.addBlock({'forEnd','value',p.gatesPerCycle});

p.s.addBlock({'GenPause','duration',p.TimeBetweenCycles});
p.s.run();

% g2serverApp.toggleMeas(0)
dump.stop();
% pause(3)
binFileToMat(fname);
[folder,name,exp]=fileparts(fname);
load(fullfile(folder,[name '.mat']));
sortedPulses=sortTimeStampsByChannels(datMat);
fprintf('%d gates received\n',length(sortedPulses{1}))
% assert(length(sortedPulses{1})==p.NAverage*p.gatesPerCycle)
tic
sortedPulses = removeEarlyPhotonsRawData(sortedPulses);

toc
tic
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,p.TimeBetweenCycles);
toc
% plot(chN_phot_time{1})
filename=fullfile(getCurrentSaveFolder,SavefileName);
SavefileName=getNextMatFileName(getCurrentSaveFolder,'MIT_','.mat');
save(filename,'chN_phot_cycles','chN_phot_gc','chN_phot_time','phot_per_cycle','chN_gates_each_cycle');

% fileparts(fullfile(getCurrentSaveFolder,SavefileName))
filename='D:\Box Sync\Lab\ExpCold\Measurements\2019\05\20\tt\multiCycleData.mat';
runs=495;
process_WIS_v1