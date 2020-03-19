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
p.ttDumpMeasurement=1;
initinst
initr
p.looping=1;

%%

p.expName = 'test tagger timing';
inst.tt.setTriggerLevel(1,0.5)
p.stepTime = 1;
p.freqNum = 3;
p.loadingTimesNum=5;
p.NAverage = 1;
p.cyclesPerRun=10;

p.randomizeLoopVals=1;
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 30;
p.probeCenterOffset=-2;
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
% p.DTParams.repumpLoadingPower = 0.035;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [6,8,5,4];
p.probePower=5e-12;
p.gateNum = 5e4;
% p.gateNum = 1;
p.NoiseGateNum = 1e3;
% p.NoiseGateNum = 1;
p.gateTime=20;
p.biasField=0.0; %gauss
p.loopVals{1} = linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;

% p.loopVals{2} = linspace(0.1e6,1.5e6,p.loadingTimesNum);
p.loopVals{2} = linspace(0.1e6,1e6,p.loadingTimesNum);
p.loopVars{2} = 'MOTLoadTime';
p.DTParams.MOTLoadTime = p.OUTERLOOPVAR;

p.innerLoopDelay = 1;
% p.DTParams.MOTLoadTime = 1e6;
p.ZeemanPumpTime=(p.gateNum+p.NoiseGateNum) * (p.gateTime+1) + 30e3 ;
p.zeemanRepumpND=[10,11]; %list with values of the ND filters used in the zeeman repump for this measurement
p.repumpTime=100;
% fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
% dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
inst.BiasFieldManager.configBpulse([NaN,p.biasField,NaN],p.ZeemanPumpTime);
p.DTParams.TrapTime=1;
p.s=sqncr();
% p.s.addBlock({'syncSetProbeLockFreq','freqJumpPause',p.freqJumpPause});
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %trapping time 



%zeeman pump
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',3,'value','high'});
p.s.addBlock({'pause','duration',3}); %zeeman pump light on
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter closes

p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'TrigScope'});
%measure
p.s.addBlock({'forStart'});
% p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
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
%measure noise
p.s.addBlock({'forStart'});
p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.NoiseGateNum});
%reset
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
load(matFileName)
figure;
gateTimes=1e-12*(double(sortedPulses{1})-double(sortedPulses{1}(1)));
% plot(gateTimes,'o-');
diffs=[];
for ind=1:floor(length(gateTimes)/2)
diffs(end+1)=gateTimes(2*ind)-gateTimes(2*ind-1);

end
variation=diffs-(p.loopVals{2}*1e-6)-0.1451;
mval=mean(variation);

hold off
plot((variation-mval)/mval,'o-');
line([1,5],[0,0],'color','black','linewidth',4)
std((diffs-(p.loopVals{2}*1e-6)-0.1451)/mval)
xlabel('iteration');
ylabel('variation from mean/mean');
%%
% loopNumsList=[length(p.loopVals{1}),length(p.loopVals{2}),p.NAverage];
% 
% parts=sliceCycleToParts(chN_phot_cycles,chN_phot_gc,phot_per_cycle,[p.gateNum/1000,p.gateNum],loopNumsList);
% sortedParts=sortRandomizedParts(parts,r);
% 
% figure;
% imagesc(p.loopVals{1},p.loopVals{2}*1e-6,sortedParts{1}')
% yticks(p.loopVals{2}*1e-6)
% ylabel('loading time [S]')
% xlabel('\delta [MHz]');
% 
% figure;
% plot(r.runValsMap{1},parts{1},'o')
% 
% figure;
% plot(p.loopVals{1},sortedParts{1},'o')
PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
figure;

dat=reshape([PhotPerCycle;NaN],30,ceil(length(PhotPerCycle)/30));

% waterfall(dat')
initParams=[1,3,1,0,-3];
lower=[0.1,1,0.6,0,-10];
upper=[5,5,1.5,0,10];
%initParams/lower/upper structure: [OD,Gamma,maxVal,bias,delta0]

figure;
for ind=1:1
subplot(3,4,ind);
f=fitExpLorentzian(p.loopVals{1},dat(:,ind)/max(dat(:,ind)),initParams,lower,upper,[-17,13]);
plot(p.loopVals{1},f(p.loopVals{1}));
% hold on
% plot(p.loopVals{1},dat(:,ind)/max(dat(:,ind)))
end

% [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=ttDumpProcessing(r.fileNames);
% 
% chN_phot_gc{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum,:) = [];
% chN_phot_gc{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum,:) = [];
% chN_phot_cycles{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum) = [];
% chN_phot_cycles{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum) = [];
% 
% fullChN_phot_cycles = chN_phot_cycles;
% fullChN_phot_gc = chN_phot_gc;
% 
% %extract noise data
% NoiseChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)>p.gateNum+p.OnePhotLineGateNum);
% NoiseChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)>p.gateNum+p.OnePhotLineGateNum);
% NoiseChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)>p.gateNum+p.OnePhotLineGateNum,:)-(p.gateNum+p.OnePhotLineGateNum);
% NoiseChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)>p.gateNum+p.OnePhotLineGateNum,:)-(p.gateNum+p.OnePhotLineGateNum);
% chN_phot_cycles = NoiseChN_phot_cycles;
% chN_phot_gc = NoiseChN_phot_gc;
% PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
% p.noiseRate = mean(PhotPerCycle)/(p.NoiseGateNum*(p.gateTime/2));
% 
% 
% chN_phot_cycles = fullChN_phot_cycles;
% chN_phot_gc = fullChN_phot_gc;
% %extract 1 photon line data data
% OnePhotChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)>p.gateNum&chN_phot_gc{1}(:,2)<=p.gateNum+p.OnePhotLineGateNum);
% OnePhotChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)>p.gateNum&chN_phot_gc{2}(:,2)<=p.gateNum+p.OnePhotLineGateNum);
% OnePhotChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)>p.gateNum&chN_phot_gc{1}(:,2)<=p.gateNum+p.OnePhotLineGateNum,:)-p.gateNum;
% OnePhotChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)>p.gateNum&chN_phot_gc{2}(:,2)<=p.gateNum+p.OnePhotLineGateNum,:)-p.gateNum;
% chN_phot_cycles = OnePhotChN_phot_cycles;
% chN_phot_gc = OnePhotChN_phot_gc;
% 
% %for fitting the one photon data 
% 
% [PhotPerCycle,PhotPerCycleSDT,~]=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
% p.bgRate = max(PhotPerCycle)/(p.OnePhotLineGateNum*p.gateTime/2);
% abso=(PhotPerCycle./(p.OnePhotLineGateNum*p.gateTime/2)-p.noiseRate)./(p.bgRate-p.noiseRate);
% absoSD=(PhotPerCycleSDT./(p.OnePhotLineGateNum*p.gateTime/2))./p.bgRate;
% absoSD(absoSD==0)=1;
% %[OD,Gamma,maxVal,bias,delta0]
% initParams=[1,3,1,0,-3];
% lower=[0.1,1,0.6,0,-10];
% upper=[5,5,1.5,0,10];
% freqs=linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,length(abso));
% [f1phot,gof1phot,~,~]=fitExpLorentzian(freqs,abso,initParams,lower,upper,[],1./absoSD);
% figure;
% errorbar(freqs,abso,absoSD);
% % plot(freqs,abso);
% hold on
% plot(f1phot)
% title(sprintf('OD=%.2f, Gamma_p = %.2f',f1phot.OD,f1phot.Gamma'))
% chN_phot_cycles = fullChN_phot_cycles;
% chN_phot_gc = fullChN_phot_gc;
% p.bgRate = f1phot.maxVal*p.bgRate;
% p.Gamma = f1phot.Gamma;
% p.OD = f1phot.OD;
% p.deltap = f1phot.delta0;
% %extract only the EIT
% EITChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<=p.gateNum);
% EITChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<=p.gateNum);
% EITChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)<=p.gateNum,:);
% EITChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)<=p.gateNum,:);
% chN_phot_cycles{1} = EITChN_phot_cycles{1};
% chN_phot_gc{1} = EITChN_phot_gc{1};
% chN_phot_cycles{2} = EITChN_phot_cycles{2};
% chN_phot_gc{2} = EITChN_phot_gc{2};
% p.supergateNum = 50;
% EIT_parameterFit_plot;
