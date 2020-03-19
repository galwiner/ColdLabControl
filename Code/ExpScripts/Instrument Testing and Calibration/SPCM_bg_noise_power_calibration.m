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
p.expName = 'probe bg calibration';
p.NAverage=1;
inst.tt.setTriggerLevel(1,0.5)
p.probeNDList = [1,3,2];
p.ZeemanNDList = [6,8,5,4];
% p.probePower=5e-11; %in mW
powerSteps=10;
p.loopVals{1} = linspace(1e-12,1e-10,powerSteps);
p.loopVars{1} = 'probePower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.gateTime=20;
fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
p.gateNum = 40000;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ScopeTrigger','value','high','duration',1e3});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time
% p.s.addBlock({'TrigScope'});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
% p.s.addBlock({'pause','duration',3e5});
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
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();

dump.stop
binFileToMat(fname);


[folder,name,exp]=fileparts(fname);
load(fullfile(folder,[name '.mat']));
sortedPulses=sortTimeStampsByChannels(datMat);
fprintf('%d gates received\n',length(sortedPulses{1}))
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,1e6,0.5);
chN_phot_gc{1}(chN_phot_cycles{1}>p.NAverage*powerSteps,:) = [];
chN_phot_gc{2}(chN_phot_cycles{2}>p.NAverage*powerSteps,:) = [];
chN_phot_cycles{1}(chN_phot_cycles{1}>p.NAverage*powerSteps) = [];
chN_phot_cycles{2}(chN_phot_cycles{2}>p.NAverage*powerSteps) = [];
chN_gates_each_cycle{1}(p.NAverage*powerSteps+1:end) = [];
PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
cycleTime = (p.gateTime/2)*mean(chN_gates_each_cycle{1});
countRateVec = PhotPerCycle./cycleTime;
setPower = p.loopVals{1};
figure;
plot(p.loopVals{1},countRateVec,'-o')
xlabel('probe set power (mW)','fontsize',16);
ylabel('outgoing count rate [phot/\mus]','fontsize',16)
hold on
lincountRateVec = spcmLinearize(countRateVec);
plot(p.loopVals{1},lincountRateVec)
% save('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\probePowerToCountRate','countRateVec','setPower');