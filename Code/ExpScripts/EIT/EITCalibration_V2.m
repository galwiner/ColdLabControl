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
p.probePower=8e-11;
loadNoise

%%
% p.gateNums = round(linspace(5000,4.5e4,8));
inst.BiasE.setZField(0);
p.gateNums = 5e3;
for ii = 1:length(p.gateNums)
%reset mot and varify zeeman switch
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.runStep();

p.expName = 'EIT Calibration V2';
p.NAverage = 3;
p.ZeemanNDList = [11];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.gateNum = p.gateNums(ii);
p.AfterGateNum = max(p.gateNums) - p.gateNums(ii)+1;
p.probeCenterOffset = -4;
p.gateTime=20;
p.biasField=-0.5; %gauss
p.DTParams.MOTLoadTime = 0.25e6;
p.preGates=1;
p.MagneticPulseTime=(max(p.gateNums)+p.preGates) * (p.gateTime+1) + 30e3; %30mS for shutter delays
p.DTParams.TrapTime=1;
p.MOTReloadTime = 1;
p.ZeemanPumpTime = 10;
nFreqs=25;
% n1=ceil(nFreqs/2);
% n2=ceil(nFreqs/3);
% n3=nFreqs-n1-n2;
% OneSidedFreqs=[linspace(0,8,n1) linspace(9,24,n2) linspace(25,100,n3)];
% p.loopVals{1} = unique([-fliplr(OneSidedFreqs) OneSidedFreqs])+p.probeCenterOffset;
p.freqNum = 30;
p.probeRampSpan = 10;
p.loopVals{1} = linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
p.cyclesPerRun=length(p.loopVals{1});
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.DTParams.MOTLoadTime = 0.25e6;

p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ProbeSwitch,'duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'pause','duration',5e3});  
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrapAndPump'});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); 
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
p.s.addBlock({'pause','duration',10}); 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
p.s.addBlock({'pause','duration',10}); 
p.s.addBlock({'forEnd','value',p.preGates});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
%measure
p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'});
p.s.addBlock({'measureSPCMWith480Control'});
% p.s.addBlock({p.compoundActions.measureSPCMOnlyProbe});
p.s.addBlock({'forEnd','value',p.gateNum});

p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.PurpleDTSwitch,'duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.BlueDTSwitch,'duration',0,'value','low'});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.PurpleDTSwitch,'duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.BlueDTSwitch,'duration',0,'value','high'});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'forEnd','value',p.AfterGateNum});
%reset
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 

p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();

% dump.stop
%

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
load(matFileName)
removeDoubleCycle;
fixMissingCycle
superGate = 100; 
sectionsList = {1:superGate:(p.gateNum+superGate)};
sectionByList = string('gate');
sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,p.NAverage);
plotList = movmean(sectionsList{1},2);plotList(1) = [];
EIT = (sectionedRes.phot_per_cycle/(superGate*p.gateTime/2)-noiseRate)/(bgRate-noiseRate);
EIT_counts = (sectionedRes.phot_per_cycle);

% figure;
% uimagesc(plotList,p.loopVals{1},EIT)

figure;
imagesc(plotList,p.loopVals{1},EIT)
title(sprintf('probe power = %0.2d',p.probePower))
colorbar
end
% keepDipoleTrapWarm;


% evenchN_phot_cycles = {};
% oddchN_phot_cycles = {};
% evenchN_phot_gc = {};
% oddchN_phot_gc = {};
% for ii = 1:2
% evenchN_phot_cycles{ii} = chN_phot_cycles{ii}(mod(chN_phot_gc{ii}(:,2),2)==0);
% % evenchN_phot_cycles{ii} = chN_phot_cycles{ii};
% oddchN_phot_cycles{ii} = chN_phot_cycles{ii}(mod(chN_phot_gc{ii}(:,2),2)~=0);
% % oddchN_phot_cycles{ii} = chN_phot_cycles{ii};
% evenchN_phot_gc{ii} = chN_phot_gc{ii}(mod(chN_phot_gc{ii}(:,2),2)==0,:)-1;
% oddchN_phot_gc{ii} = chN_phot_gc{ii}(mod(chN_phot_gc{ii}(:,2),2)~=0,:);
% end
% superGate = 500; 
% sectionsList = {1:superGate:(p.gateNum*2+superGate)};
% sectionByList = string('gate');
% evensectionedRes = sectionTTResV2(evenchN_phot_cycles,evenchN_phot_gc,chN_phot_time,sectionsList,sectionByList,p.NAverage);
% oddsectionedRes = sectionTTResV2(oddchN_phot_cycles,oddchN_phot_gc,chN_phot_time,sectionsList,sectionByList,p.NAverage);
% figure;imagesc(evensectionedRes.phot_per_cycle)
% % figure;imagesc(1:120,p.loopVals{1}(1:end-1),oddsectionedRes.phot_per_cycle)
% figure;uimagesc(1:size(oddsectionedRes.phot_per_cycle,2),p.loopVals{1}(1:end),oddsectionedRes.phot_per_cycle)
% figure;uimagesc(1:size(evensectionedRes.phot_per_cycle,2),p.loopVals{1}(1:end),evensectionedRes.phot_per_cycle)
% 
% % plotList = sectionsList{1}(2:end-1);
% % EIT = (sectionedRes.phot_per_cycle/(superGate*p.gateTime/2)-noiseRate)/(bgRate-noiseRate);
% % % EIT = (sectionedRes.phot_per_cycle);
% % figure;
% % imagesc(plotList,p.loopVals{1},EIT)
% % title(sprintf('probe power = %0.2d',p.probePower))
% % colorbar
% 
