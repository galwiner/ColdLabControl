clear all
global p
global r
global inst
initp
p.hasTTresults = 1;
p.ttDumpMeasurement=1;
p.hasScopResults=0;
initinst
initr
p.probeNDList = [13,3,2];
%%
p.gateNum = 30e3;
p.expName = 'test probe pulse';
p.blueAOMVVAN = 5.6;
p.probePower=8e-11;
p.NAverage = 50;
p.cyclesPerRun = 10;
p.gateTime = 20;
p.s=sqncr();
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
%measure
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'forStart'});
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
% p.s.addBlock({'pause','duration',p.gateTime/2});
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
% p.s.addBlock({'pause','duration',p.gateTime/2});
% % p.s.addBlock({p.compoundActions.measureSPCMOnlyProbe});
p.s.addBlock({p.compoundActions.measureSPCMWith480Control});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 

p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();


[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
load(matFileName)
removeDoubleCycle;
fixMissingCycle
%
dt = 0.05; 
sectionsList = {0:dt:(p.gateTime/2+1)};
sectionByList = string('timeingate');
sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,p.NAverage);
plotList = movmean(sectionsList{1},2);plotList(1) = [];
pulseShape = sectionedRes.phot_per_cycle;
figure;
plot(plotList,pulseShape)
title(sprintf('probe polse shape. blueAOMVVAN = %0.1f V, probe power = %0.2d',p.blueAOMVVAN,p.probePower))
