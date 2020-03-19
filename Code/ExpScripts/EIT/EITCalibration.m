clear all
global p
global r
global inst
initp
p.hasTTresults = 1;
p.ttDumpMeasurement=1;

p.hasScopResults=1;
initinst
initr
p.probePower=3e-11;
loadNoise
%%

%reset mot and varify zeeman switch
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.runStep();

p.expName = 'EIT Calibration';
p.freqNum = 1;
p.NAverage = 1;
p.cyclesPerRun=20;
p.probeRampSpan = 16;
p.probeCenterOffset=-4;
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [8];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.gateNum = 10000;
p.OnePhotLineGateNum = 1e3;
% p.NoiseGateNum = 1e3;
p.NoiseGateNum = 0; %changed to 0 at 23/09 because we load noise inependently.
p.ODRefGateNum = 1e3;
p.gateTime=20;
p.biasField=-0.5; %gauss
p.loopVals{1} = linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.DTParams.MOTLoadTime = 0.25e6;
p.MagneticPulseTime=(p.gateNum+p.NoiseGateNum+p.OnePhotLineGateNum +p.ODRefGateNum) * (p.gateTime+1) + 30e3 +40e3;
p.repumpTime=100;

inst.BiasFieldManager.configBpulse([NaN,p.biasField,NaN],p.MagneticPulseTime);
p.DTParams.TrapTime=1;
% p.DTParams.TrapTime=40e3;
p.MOTReloadTime = 1;
p.zeemanPumpOn=1;
p.ZeemanPumpTime = 20;
p.controlPower = 465; %in mW directly after fiber
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'pause','duration',5e3});  
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3});
%zeeman pump
if p.zeemanPumpOn
    zeemanChanVal='high';   
else   
    p.s.addBlock({'setRepumpPower','duration',0,'value',18});
    p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
    p.s.addBlock({'pause','duration',p.repumpTime});
    zeemanChanVal='low';   
end

p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',p.ZeemanPumpTime,'value',zeemanChanVal});
p.s.addBlock({'pause','duration',p.ZeemanPumpTime}); %zeeman pump light on
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter closes
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',45e3}); %additional trapping time 
% p.s.addBlock({'TrigScope'});
%measure
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.ODRefGateNum});

p.s.addBlock({'TrigScope'});

p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.gateNum});
%measure 1 photon line
% p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'});
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
p.s.addBlock({'forEnd','value',p.OnePhotLineGateNum});
% %measure noise
% p.s.addBlock({'forStart'});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
% p.s.addBlock({'pause','duration',p.gateTime/2});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); 
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
% p.s.addBlock({'pause','duration',p.gateTime/2});
% p.s.addBlock({'forEnd','value',p.NoiseGateNum});
%reset
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();

% dump.stop
%
% keepDipoleTrapWarm;
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=ttDumpProcessing(r.fileNames);
% datMatFile=binFileListToMat(r.fileNames);
% load(datMatFile);
% 
% 
% % binFileToMat(fname);
% % 
% % 
% % [folder,name,exp]=fileparts(fname);
% % load(fullfile(folder,[name '.mat']));
% %
% 
% 
% sortedPulses=sortTimeStampsByChannels(datMat);
% fprintf('%d gates received\n',length(sortedPulses{1}))
% [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,p.DTParams.MOTLoadTime,0.5);
%remove extra cycles
%% 
% loadNoise
% chN_phot_gc{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum,:) = [];
% chN_phot_gc{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum,:) = [];
% chN_phot_cycles{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum) = [];
% chN_phot_cycles{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum) = [];
% load(getLastTTfile);
% removeDoubleCycle;
% fixMissingCycle;
% idx = {};
% idx{1} = chN_phot_time{1}(:,2)>1.2;
% idx{2} = chN_phot_time{2}(:,2)>1.2;
% chN_phot_cycles{1} = chN_phot_cycles{1}(idx{1});
% chN_phot_gc{1} = chN_phot_gc{1}(idx{1},:);
% chN_phot_cycles{2} = chN_phot_cycles{2}(idx{2});
% chN_phot_gc{2} = chN_phot_gc{2}(idx{2},:);
fullChN_phot_cycles = chN_phot_cycles;
fullChN_phot_gc = chN_phot_gc;

%extract noise data
% NoiseChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)>p.gateNum+p.OnePhotLineGateNum);
% NoiseChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)>p.gateNum+p.OnePhotLineGateNum);
% NoiseChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)>p.gateNum+p.OnePhotLineGateNum,:)-(p.gateNum+p.OnePhotLineGateNum);
% NoiseChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)>p.gateNum+p.OnePhotLineGateNum,:)-(p.gateNum+p.OnePhotLineGateNum);
% chN_phot_cycles = NoiseChN_phot_cycles;
% chN_phot_gc = NoiseChN_phot_gc;
% PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
% p.noiseRate = mean(PhotPerCycle)/(p.NoiseGateNum*(p.gateTime/2));
p.noiseRate = noiseRate;
p.bgRate = bgRate;
chN_phot_cycles = fullChN_phot_cycles;
chN_phot_gc = fullChN_phot_gc;
%extract 1 photon line data data
OnePhotChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)>(p.gateNum+p.ODRefGateNum)&chN_phot_gc{1}(:,2)<=p.gateNum+p.OnePhotLineGateNum+p.ODRefGateNum);
OnePhotChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)>p.gateNum+p.ODRefGateNum&chN_phot_gc{2}(:,2)<=p.gateNum+p.OnePhotLineGateNum+p.ODRefGateNum);
OnePhotChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)>p.gateNum+p.ODRefGateNum&chN_phot_gc{1}(:,2)<=p.gateNum+p.OnePhotLineGateNum+p.ODRefGateNum,:)-p.gateNum;
OnePhotChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)>p.gateNum+p.ODRefGateNum&chN_phot_gc{2}(:,2)<=p.gateNum+p.OnePhotLineGateNum+p.ODRefGateNum,:)-p.gateNum;
chN_phot_cycles = OnePhotChN_phot_cycles;
chN_phot_gc = OnePhotChN_phot_gc;

%for fitting the one photon data 

[PhotPerCycle,PhotPerCycleSDT,~]=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
% p.bgRate = max(PhotPerCycle)/(p.OnePhotLineGateNum*p.gateTime/2);
abso=(PhotPerCycle./(p.OnePhotLineGateNum*p.gateTime/2)-p.noiseRate)./(p.bgRate-p.noiseRate);
absoSD=(PhotPerCycleSDT./(p.OnePhotLineGateNum*p.gateTime/2))./p.bgRate;
absoSD(absoSD==0)=1;
%[OD,Gamma,maxVal,bias,delta0]
initParams=[1,3,1,0,-3];
lower=[0.1,1,0.6,0,-10];
upper=[5,5,1.5,0,10];
freqs=linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,length(abso));
[f1phot,gof1phot,~,~]=fitExpLorentzian(freqs,abso,initParams,lower,upper,[],1./absoSD);
figure;
errorbar(freqs,abso,absoSD);
% plot(freqs,abso);
hold on
plot(f1phot)
title(sprintf('OD=%.2f, Gamma_p = %.2f',f1phot.OD,f1phot.Gamma'))
chN_phot_cycles = fullChN_phot_cycles;
chN_phot_gc = fullChN_phot_gc;
p.bgRate = f1phot.maxVal*p.bgRate;
p.Gamma = f1phot.Gamma;
p.OD = f1phot.OD;
p.deltap = f1phot.delta0;
%extract only the EIT
EITChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<=(p.gateNum+p.ODRefGateNum)&chN_phot_gc{1}(:,2)>p.ODRefGateNum);
EITChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<=(p.gateNum+p.ODRefGateNum)&chN_phot_gc{2}(:,2)>p.ODRefGateNum);
EITChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)<=(p.gateNum+p.ODRefGateNum)&chN_phot_gc{1}(:,2)>p.ODRefGateNum,:);
EITChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)<=(p.gateNum+p.ODRefGateNum)&chN_phot_gc{2}(:,2)>p.ODRefGateNum,:);
chN_phot_cycles{1} = EITChN_phot_cycles{1};
chN_phot_gc{1} = EITChN_phot_gc{1};
chN_phot_cycles{2} = EITChN_phot_cycles{2};
chN_phot_gc{2} = EITChN_phot_gc{2};
p.supergateNum = 50;
p.startGate = 1e3;
EIT_parameterFit_plot;

chN_phot_cycles = fullChN_phot_cycles;
chN_phot_gc = fullChN_phot_gc;
%extract OD fit data
ODChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<=p.ODRefGateNum);
ODChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<=p.ODRefGateNum);
ODChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)<=p.ODRefGateNum,:);
ODChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)<=p.ODRefGateNum,:);
chN_phot_cycles{1} = ODChN_phot_cycles{1};
chN_phot_gc{1} = ODChN_phot_gc{1};
chN_phot_cycles{2} = ODChN_phot_cycles{2};
chN_phot_gc{2} = ODChN_phot_gc{2};
[PhotPerCycle,PhotPerCycleSDT,~]=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
abso=(PhotPerCycle./(p.ODRefGateNum*p.gateTime/2)-p.noiseRate)./(p.bgRate-p.noiseRate);
absoSD=(PhotPerCycleSDT./(p.OnePhotLineGateNum*p.gateTime/2))./p.bgRate;
absoSD(absoSD==0)=1;
%[OD,Gamma,maxVal,bias,delta0]
initParams=[30,p.Gamma,1,-0.04,-3];
lower=[0.1,p.Gamma,1,-0.05,-inf];
upper=[inf,p.Gamma,1,-0.03,inf];
freqs=linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,length(abso));
[f1phot,gof1phot,~,~]=fitExpLorentzian(freqs,abso,initParams,lower,upper,[]);
figure;
plot(freqs,abso);
% plot(freqs,abso);
hold on
plot(f1phot)
title(sprintf('OD=%.2f, Gamma_p = %.2f',f1phot.OD,f1phot.Gamma'))
