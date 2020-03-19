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
p.expName = 'spcm gating time test';
%%
p.randomizeLoopVals=1;
inst.tt.setTriggerLevel(1,0.5)
p.probeNDList = [1,3,2];
p.gateNums = 1000;
p.NAverage = 1;
p.notificationOn=0;
p.innerLoopDelay = 1;
p.pauseBetweenRunSteps=0;
fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
p.probePower=1e-11;
nTimes=5;
p.loopVals{1} = linspace(0.1e6,1e6,nTimes);
p.loopVars{1} = 'inter_cycle_pasue_duration';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s=sqncr();

p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
%measure
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','high','duration',0});
p.s.addBlock({'pause','duration',5e3}); 
p.s.addBlock({'forStart'});
p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row

p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});

p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});

p.s.addBlock({'pause','duration',10});
p.s.addBlock({'forEnd','value',p.gateNums});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0});
p.s.addBlock({'pause','duration',5e3}); 
%reset
p.s.addBlock({'GenPause','duration',p.inter_cycle_pasue_duration});
p.s.run();

dump.stop


binFileToMat(fname);
pause(3)
[folder,file]=fileparts(fname);
load(fullfile(folder,[file '.mat']));

sortedPulses=sortTimeStampsByChannels(datMat);
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,100e3,0.5);

figure;
subplot(2,1,1)
x1=chN_phot_time{1}(:,1);
x2=chN_phot_time{2}(:,1);
stem(x1,ones(size(x1)))
subplot(2,1,2)
stem(x2,ones(size(x2)))

figure;
plot(chN_phot_time{1}(:,1),chN_phot_cycles{1},'o')
hold on
plot(chN_phot_time{2}(:,1),chN_phot_cycles{2},'o')
title(sprintf('%d, %d',max(chN_phot_cycles{1}),max(chN_phot_cycles{2})))
% assert(max(chN_phot_cycles{1})==p.NAverage*nTimes)
% assert(max(chN_phot_cycles{2})==p.NAverage*nTimes)

