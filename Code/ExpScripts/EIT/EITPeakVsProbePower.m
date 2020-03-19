clear all
global p
global r
global inst
initp
p.hasTTresults = 1;
p.ttDumpMeasurement=1;
initinst
initr
p.probePower = 1e-11;
loadNoise
%%
p.probeDet = -5.5;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.runStep();

p.expName = 'EIT Peak vs Probe Power';
p.NAverage = 10;
p.stepNum = 10;
p.cyclesPerRun=10;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [8];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.gateNum = 2e3;
p.bgGates = 1e4;
p.gateTime=20;
p.biasField=-0.5; %gauss
p.loopVals{1} = logspace(-11,-9,p.stepNum);
p.loopVars{1} = 'probePower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.DTParams.MOTLoadTime = 0.25e6;
p.MagneticPulseTime=(p.gateNum) * (p.gateTime+1) + 30e3 ;
p.repumpTime=100;

inst.BiasFieldManager.configBpulse([NaN,p.biasField,NaN],p.MagneticPulseTime);
p.DTParams.TrapTime=1;
p.MOTReloadTime = 1;
p.zeemanPumpOn=1;
p.ZeemanPumpTime = 20;
p.controlPower = 465;%in mW directly after fiber
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ProbeSwitch,'duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'pause','duration',5e3});  
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrapAndPump'});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
%measure
p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'});
p.s.addBlock({'measureSPCMWith480Control'});
p.s.addBlock({'forEnd','value',p.gateNum});

p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',10e3});

p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'});
p.s.addBlock({'measureSPCMWith480Control'});
p.s.addBlock({'forEnd','value',p.bgGates});
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

keepDipoleTrapWarm;

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=ttDumpProcessing(r.fileNames);

%% plotting
[fname,fnum,prefix]=getLastpFile;
[ttfname,ttfnum,ttprefix]=getLastTTfile;
load(ttfname)
load(fname)
% fixMissingCycle;
% removeDoubleCycle;
% numGate = 1e3;
% startGate = 1e3:numGate:9e3;
% 
% totGate = 1e4;
% %
% trans = zeros(21,9);
% for  ii = 1:length(startGate)
%     if ii ==1
%         EIT_ChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<=startGate(ii));
%         EIT_ChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<startGate(ii));
%         EIT_ChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)<=startGate(ii),:);
%         EIT_ChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)<=startGate(ii),:);
%     else
%         EIT_ChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<=startGate(ii) & chN_phot_gc{1}(:,2)>startGate(ii-1));
%         EIT_ChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<startGate(ii) & chN_phot_gc{2}(:,2)>startGate(ii-1));
%         EIT_ChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)<=startGate(ii) & chN_phot_gc{1}(:,2)>startGate(ii-1),:);
%         EIT_ChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)<startGate(ii) & chN_phot_gc{2}(:,2)>startGate(ii-1)<=startGate(ii),:);
%     end
% 
% noise_ChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)>startGate(ii)+totGate & chN_phot_gc{1}(:,2)<=(startGate(ii)+totGate+numGate));
% noise_ChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)>startGate(ii)+totGate & chN_phot_gc{2}(:,2)<=(startGate(ii)+totGate+numGate));
% noise_ChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)>startGate(ii)+totGate & chN_phot_gc{1}(:,2)<=(startGate(ii)+totGate+numGate),:);
% noise_ChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)>startGate(ii)+totGate & chN_phot_gc{2}(:,2)<=(startGate(ii)+totGate+numGate),:);
% 
% bg_ChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)>(startGate(ii)+2*totGate) & chN_phot_gc{1}(:,2)<(startGate(ii)+2*totGate+numGate));
% bg_ChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)>(startGate(ii)+2*totGate) & chN_phot_gc{2}(:,2)<(startGate(ii)+2*totGate+numGate));
% bg_ChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)>(startGate(ii)+2*totGate) & chN_phot_gc{1}(:,2)<(startGate(ii)+2*totGate+numGate),:);
% bg_ChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)>(startGate(ii)+2*totGate) & chN_phot_gc{2}(:,2)<(startGate(ii)+2*totGate+numGate),:);
% 
% chN_phot_cycles = EIT_ChN_phot_cycles;
% chN_phot_gc = EIT_ChN_phot_gc;
% mean_eit_phot_per_cycle(:,ii) = removeBadCyclesandMean(EIT_ChN_phot_cycles,p.NAverage);
% mean_noise_phot_per_cycle(:,ii) = removeBadCyclesandMean(noise_ChN_phot_cycles,p.NAverage);
% mean_bg_phot_per_cycle(:,ii) = removeBadCyclesandMean(bg_ChN_phot_cycles,p.NAverage);
% trans(:,ii) = (mean_eit_phot_per_cycle(:,ii)-mean_noise_phot_per_cycle(:,ii))./(mean_bg_phot_per_cycle(:,ii)-mean_noise_phot_per_cycle(:,ii));
% 
% end
sectionsList = {[1,2000,1.4e4]};
sectionByList = string('gate');
sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,p.NAverage);

transRate = sectionedRes.phot_per_cycle(:,1)/(p.gateNum*p.gateTime/2)-p.noiseRate;
bgRate = sectionedRes.phot_per_cycle(:,2)/(p.bgGates*p.gateTime/2)-p.noiseRate;
figure;
semilogx(p.loopVals{1},transRate./bgRate)
% couplingEfficiency=0.50;
% QE=0.7;
% 
% inputRate=mean_bg_phot_per_cycle/(p.gateNum*p.gateTime/2)/QE/couplingEfficiency;
% figure;plot(p.loopVals{1})
% xlabel('input power [mW]');
% ylabel('input photons / uS');
% 
% title('photon input rate calibration');
% 
% 
% figure;
% plot(mean_bg_phot_per_cycle(:,ii))
% % [fname,fnum,prefix]=getLastpFile;
% 
% % [ttfname,ttfnum,ttprefix]=getLastTTfile;
% % load(ttfname)
% % load(fname)
% % loadNoise
% % fixMissingCycle;
% % removeDoubleCycle;
% % mean_phot_per_cycle = removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
% % bgRate = probePower2CountRate(p.loopVals{1});
% % trans = (mean_phot_per_cycle'/(p.gateNum*p.gateTime/2)-noiseRate)./(bgRate-noiseRate);
% 
% figure;
% for ii = 1:length(startGate)
% subplot(3,4,ii)
% semilogx(inputRate(:,ii),trans(:,ii),'o-')
% xticklabels([0.1,1,10])
% xlabel('photons / uS');
% ylabel('Trasmission on EIT peak')
% % title('Probe power sweep, 10 averages, control power 460mW (on atoms)')
% set(gca,'FontSize',14)
% grid on
% end
% % subplot(1,2,2)
% % if length(trans)~=p.loopVals{1}
% %     semilogx(p.loopVals{1},trans(1:length(p.loopVals{1})),'o-')
% % else
% %     semilogx(p.loopVals{1},trans,'o-')
% % end
% % % xticklabels([0.1,1,10])
% % xlabel('photons / uS');
% % ylabel('Trasmission on EIT peak')
% % title('Probe power sweep, 10 averages, control power 460mW (on atoms)')
% % set(gca,'FontSize',14)
% % grid on
