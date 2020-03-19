
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
p.ttDumpMeasurement=1;
p.hasTTresults = 1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
p.chanList = 2;
initinst
initr
p.looping=1;

%%
p.expName = 'Zeeman Pump Probe Spectroscopy';

p.stepTime = 1;
p.freqNum = 25;
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 40;
p.probeCenterOffset=-4;
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
p.BiasField=0.5;
% p.DTParams.repumpLoadingPower = 0.035;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [8,6];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.probePower=1e-11; %in mW
p.cyclesPerRun=10;
p.randomizeLoopVals=0;
p.gateNum=50000;

% inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)
% pause(2)
p.loopVals{1} = fliplr(linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum));
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.NAverage = 1;
p.innerLoopDelay = 1;
p.DTParams.MOTLoadTime = 0.1e6;
p.gateTime = 20;
p.ZeemanPumpTime=p.gateNum * (p.gateTime+1) + 30e3 ;
p.MOTReloadTime = 1;
% fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
% dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
inst.BiasFieldManager.configBpulse([NaN,p.BiasField,NaN],p.ZeemanPumpTime);
% p.DTParams.TrapTime=0.1e6;
p.DTParams.TrapTime = 1;
p.repumpTime = 100;
% testLoc
for ii = 1:1
resetProbeLock(p.loopVals{1})
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});

p.s.addBlock({'LoadDipoleTrap'});
%%cooling repump
% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
% p.s.addBlock({'pause','duration',p.repumpTime});

p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %this must be at least 10 ms, to let the magnetic field time to settle
%zeeman pump
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',3,'value','high'});
p.s.addBlock({'pause','duration',3});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter. 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 


% p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 

% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
% p.s.addBlock({'pause','duration',5e3}); %additional trapping time 

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
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});

p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e5});

p.s.run();
end
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
mean_phot_per_cycle = meanPhot_per_cycle(phot_per_cycle,p.NAverage);
% figure;
% plot(p.loopVals{1}(1:length(mean_phot_per_cycle)),mean_phot_per_cycle./max(mean_phot_per_cycle),'-o')
% figure
% plot(phot_per_cycle./max(phot_per_cycle),'-o')

% dump.stop
% binFileToMat(fname);
% 
% 
% [folder,name,exp]=fileparts(fname);
% load(fullfile(folder,[name '.mat']));
% sortedPulses=sortTimeStampsByChannels(datMat);
% fprintf('%d gates received\n',length(sortedPulses{1}))
% [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,0.01e6,0.5);
% % plotTTRes(chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle)
% chN_phot_gc{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum,:) = [];
% chN_phot_gc{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum,:) = [];
% chN_phot_cycles{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum) = [];
% chN_phot_cycles{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum) = [];
% 
% % p.supergateNum = 50;
% % sectioned_OD_plot;
p.supergateNum = 30;
p.NAverage = 1;
sectioned_Spectroscopy_plot
PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
% PhotPerCycle = fliplr(PhotPerCycle')';
% % % 
% freqs=linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
% %
% figure;
% if length(freqs)==length(PhotPerCycle)
%     plot(freqs,PhotPerCycle./max(PhotPerCycle))
% %     initParams = [5,3.05,1,-0.02,-3];
% %     lowPar = [0,3.05,0.9,-0.04,-6];
% %     upPar = [100,3.05,1.1,-0.01,4];
% %     [f,gof,~,~]=fitExpLorentzian(freqs',PhotPerCycle./max(PhotPerCycle),initParams,lowPar,upPar);
% %     hold on
% %     plot(freqs,f(freqs),'-r');
%     xlabel('delta [MHz]');
% %     dim = [.2 .5 .8 .3];
% %     confs=confint(f);
% %     
% %     str=sprintf('OD = %.2f [%.2f,%.2f]',f.OD,confs(1,1),confs(2,1));
% %     annotation('textbox',dim,'String',str,'FitBoxToText','on');
%     
% elseif length(freqs)>length(PhotPerCycle)
%     plot(freqs(1:length(PhotPerCycle)),PhotPerCycle./max(PhotPerCycle))
%     xlabel('delta [MHz]')
% elseif length(freqs)<length(PhotPerCycle)
%         plot(freqs,PhotPerCycle(1:freqs)./max(PhotPerCycle))
%     xlabel('delta [MHz]')
% end
% ylabel('counts per gate (10 uS)');
% title(sprintf('probe power = %.1e pW',1e9*p.probePower))