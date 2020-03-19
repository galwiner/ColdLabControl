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
p.expName = 'SPCMLongTimeGateTest';
%%
inst.tt.setTriggerLevel(2,0.5);
inst.tt.setTriggerLevel(3,0.5);
fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
inst.tt.setTriggerLevel(1,0.5)
p.trigPulseTime = 1;
p.gateNums = 1000;
p.NAverage = 100;
p.repumpTime = 10;
p.DTParams.MOTLoadTime = 1e4;
p.DTParams.LoadingTime = 1;
% p.pauseTime = p.DTParams.MOTLoadTime+p.DTParams.LoadingTime+p.DTParams.secondStageTime+p.DTParams.TrapTime;
p.pauseTime = 0.5e6;
p.MOTReloadTime = 1;
p.s=sqncr();

% p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'pause','duration',p.pauseTime});
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

p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',p.trigPulseTime});
p.s.addBlock({'forStart'});
p.s.addBlock({'pause','duration',1});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',10});
% p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'forEnd','value',p.gateNums});
%reset
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e4});
p.s.run();

dump.stop
binFileToMat(fname);
[folder,name,exp]=fileparts(fname);
load(fullfile(folder,[name '.mat']));
sortedPulses=sortTimeStampsByChannels(datMat);
fprintf('%d gates received\n',length(sortedPulses{1}))
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,1e5,0.5);
%
% setFreqs = linspace((p.probeLockCenter-p.probeRampSpan/2),(p.probeLockCenter+p.probeRampSpan/2),length(p.loopVals{1}));
% 
% for ii = 1:length(p.loopVals{1})
%    photCount(ii) =  length(find(chN_phot_cycles{1}==ii))+length(find(chN_phot_cycles{2}==ii));
% end
% figure;
% plot(setFreqs,photCount);
plotTTRes(chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle)