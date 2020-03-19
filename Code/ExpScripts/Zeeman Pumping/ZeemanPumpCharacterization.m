
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
p.chanList = 1;
initinst
initr
p.looping=1;
p.probePower=5e-11; %in mW
loadNoise
%%

p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.runStep();


p.expName = 'Zeeman Pump Characterization';
p.pumpingCycles = 8;
p.freqNum = 35;
p.probeRampSpan = 50;
p.probeCenterOffset=-4;
p.BiasField=-0.5;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [11];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.cyclesPerRun=p.freqNum;
p.gateNum=2000;
p.NAverage = 1;
p.DTParams.MOTLoadTime = 0.25e6;
p.gateTime = 20;
p.MagneticPulseTime=p.gateNum * (p.gateTime+1) + 30e3 ;
p.MOTReloadTime = 1;
p.ZeemanPumpTime = 10;
p.zeemanPumpOn=1;
inst.BiasFieldManager.configBpulse([NaN,p.BiasField,NaN],p.MagneticPulseTime);
p.DTParams.TrapTime = 1;
p.repumpTime = 100;
cycleTime = p.gateNum*p.gateTime/2;

repeatNumber=1; %the number of iterations (for monitoring OD variations)
p.notificationOn=1;
p.probeCenterOffset=-270;
two2twoLoopVals=(linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum));
p.probeCenterOffset=-4;
two2threeLoopVals = (linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum));

for ind =1:repeatNumber
% 1st stage: measure the 2->3 transition 
p.probeCenterOffset=-4;
p.loopVals{1} = two2threeLoopVals;
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','low'}); %zeeman AOM low, comment out to revert
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %this must be at least 10 ms, to let the magnetic field time to settle
%zeeman pump
if p.zeemanPumpOn
    zeemanChanVal='high';   
else   
    p.s.addBlock({'setRepumpPower','duration',0,'value',18});
    p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
    p.s.addBlock({'pause','duration',p.repumpTime});
    zeemanChanVal='low';   
end
p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',p.ZeemanPumpTime,'value',zeemanChanVal});
p.s.addBlock({'pause','duration',p.ZeemanPumpTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.ZeemanPumpTime});
p.s.addBlock({'forEnd','value',p.pumpingCycles});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter. 

p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
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
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();
p.probeCenterOffset=-270;
p.loopVals{1} = two2twoLoopVals;
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
resetProbeLock([two2twoLoopVals(1),two2threeLoopVals(end)])
pause(0.3);
%2nd stage: measure the 2->2 transition 
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','low'}); %zeeman AOM low, comment out to revert
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %this must be at least 10 ms, to let the magnetic field time to settle
%zeeman pump
if p.zeemanPumpOn
    zeemanChanVal='high';   
else 
    p.s.addBlock({'setRepumpPower','duration',0,'value',18});
    p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
    p.s.addBlock({'pause','duration',p.repumpTime});
    zeemanChanVal='low';
end
p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',p.ZeemanPumpTime,'value',zeemanChanVal});
p.s.addBlock({'pause','duration',p.ZeemanPumpTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.ZeemanPumpTime});
p.s.addBlock({'forEnd','value',p.pumpingCycles});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter. 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
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
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});%zeeman AOM high, comment out to revert
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();
resetProbeLock([two2threeLoopVals(1),two2twoLoopVals(end)]);
end
detVals = p.loopVals{1};
keepDipoleTrapWarm
%%processing 07/11/19
[fname,fnum,prefix]=getLastpFile;
[ttfname,ttfnum,ttprefix]=getLastTTfile;
plist = (fnum-(2*repeatNumber-1)):fnum;
ttlist = (ttfnum-(2*repeatNumber-1)):ttfnum;
dets = linspace(-4-p.probeRampSpan/2,-4+p.probeRampSpan/2,p.freqNum);
for ii = 1:length(plist)
    matFile=fullfile(getCurrentSaveFolder,['tt_120919_' num2str(ttlist(ii),'%02d') '__Zeeman Pump Characterization.mat']);
    load([prefix, num2str(plist(ii),'%02d'), '.mat']);
    p.noiseRate=noiseRate;
    p.bgRate=bgRate;
    if exist(matFile)
        load(matFile)
        fixMissingCycle
        removeDoubleCycle
        disp('mat file loaded');
    else
        [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
        load(matFileName)
        fixMissingCycle
        removeDoubleCycle
    end
    if mod(ii,2)==0
        two2twoAbso = (phot_per_cycle/cycleTime-p.noiseRate)/(p.bgRate-p.noiseRate);
        
        %         fitExpLorentzian(delta,y,initParams,lower,upper,bounds,varargin)
        % [OD,Gamma,maxVal,bias,delta0]
        ip22 = [1,3.05,1,0,-4];
        lp22 = [0,3.05,0.95,0,-inf];
        up22 = [inf,3.05,1.05,0,inf];
        f22 = fitExpLorentzian(dets,two2twoAbso,ip22,lp22,up22);
    else
        two2threeAbso = (phot_per_cycle/cycleTime-p.noiseRate)/(p.bgRate-p.noiseRate);
        ip23 = [30,3.05,1,0,-4];
        lp23 = [0,3.05,0.95,0,-6];
        up23 = [inf,3.05,1.05,0,-2];
        f23 = fitExpLorentzian(dets,two2threeAbso,ip23,lp23,up23);
    end
end
fitDets = linspace(min(dets),max(dets),1e3);
figure;
subplot(1,2,1)
plot(dets,two2threeAbso,'o')
hold on
plot(fitDets,f23(fitDets))
subplot(1,2,2)
plot(dets,two2twoAbso,'o')
hold on
plot(fitDets,f22(fitDets))
[pumpingEff,mf2] = getPumpingEffitiency(f23.OD/f22.OD,0);
suptitle(sprintf('pump ND List = %s. pumping effitiency = %0.1f, pumped OD = %0.2f',num2str(p.ZeemanNDList),pumpingEff,getPumpedOD(f23.OD,mf2,0)));
%% processing

% [fname,fnum,prefix]=getLastpFile;
% [ttfname,ttfnum,ttprefix]=getLastTTfile;
% plist = (fnum-(2*repeatNumber-1)):fnum;
% ttlist = (ttfnum-(2*repeatNumber-1)):ttfnum;
% % freqs = linspace(min(p.loopVals{1
% figure;
% gca
% hold on
% 
% for ii = 1:length(plist)
%     matFile=fullfile(getCurrentSaveFolder,['tt_120919_' num2str(ttlist(ii),'%02d') '__Zeeman Pump Characterization.mat']);
%     load([prefix, num2str(plist(ii),'%02d'), '.mat']);
%         p.noiseRate=noiseRate;
%     p.bgRate=bgRate;
%     if exist(matFile)
%         load(matFile)
%         disp('mat file loaded');
%     else
%         [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
%     end
% %     load(fullfile(prefix,['tt_120919_' num2str(plist(ii),'%02d') '__Zeeman Pump Characterization.mat']));
% %     two2three_phot_per_cycle=phot_per_cycle;
% %     two2two_phot_per_cycle=phot_per_cycle;
%     if mod(ii,2)==0
%         two2twoAbsoStep = (phot_per_cycle/cycleTime-p.noiseRate)/(p.bgRate-p.noiseRate);
%         dets = p.loopVals{1}+266;
%         if length(two2twoAbsoStep)~=length(dets)
%             dets = linspace(min(dets),max(dets),length(two2twoAbsoStep));
%         end
%         subplot(1,2,2)
%         plot(dets,two2twoAbsoStep,'DisplayName',num2str(ii))
%         hold on
%         title("F=2 -> F'=2")
%         legend();
%     else 
%         two2threeAbsoStep = (phot_per_cycle/cycleTime-p.noiseRate)/(p.bgRate-p.noiseRate);
%         dets = p.loopVals{1};
%         if length(two2threeAbsoStep)~=length(dets)
%             dets = linspace(min(dets),max(dets),length(two2threeAbsoStep));
%         end
%         subplot(1,2,1)
%         plot(dets,two2threeAbsoStep,'DisplayName',num2str(ii))
%         hold on
%         title("F=2 -> F'=3")
%         legend  
%     end
% end
%%
% [fname,fnum,prefix]=getLastpFile;
% [ttfname,ttfnum,ttprefix]=getLastTTfile;
% plist = (fnum-(2*repeatNumber-1)):fnum;
% ttlist = (ttfnum-(2*repeatNumber-1)):ttfnum;
% two2twoAbsoStep = zeros(length(p.loopVals{1}),0);
% two2threeAbsoStep = zeros(length(p.loopVals{1}),0);
% % plist = 35:fnum;
% % ttlist = 35:ttfnum;
% for ii = 1:length(plist)
%     matFile=fullfile(getCurrentSaveFolder,['tt_120919_' num2str(ttlist(ii),'%02d') '__Zeeman Pump Characterization.mat']);
%     load([prefix, num2str(plist(ii),'%02d'), '.mat']);
%     p.noiseRate=noiseRate;
%     p.bgRate=bgRate;
%     if exist(matFile)
%         load(matFile)
%         disp('mat file loaded');
%     else
%         [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
%     end
% %     load(fullfile(prefix,['tt_120919_' num2str(plist(ii),'%02d') '__Zeeman Pump Characterization.mat']));
% %     two2three_phot_per_cycle=phot_per_cycle;
% %     two2two_phot_per_cycle=phot_per_cycle;
% if length(phot_per_cycle)< length(p.loopVals{1})
%     phot_per_cycle(end:length(p.loopVals{1})) = nan;
% elseif length(phot_per_cycle)> length(p.loopVals{1})
%     phot_per_cycle((length(p.loopVals{1})+1):end) = [];
% end
%     if mod(ii,2)==0
%         two2twoAbsoStep(:,end+1) = (phot_per_cycle/cycleTime-p.noiseRate)/(p.bgRate-p.noiseRate);
%     else 
%         two2threeAbsoStep(:,end+1) = (phot_per_cycle/cycleTime-p.noiseRate)/(p.bgRate-p.noiseRate);
%     end
% end
% figure;
% subplot(1,2,1)
% imagesc(two2threeAbsoStep)
% subplot(1,2,2)
% imagesc(two2twoAbsoStep)
%% zeeman power variation
% stage1_cut=squeeze(stage1_scpRes(1.1e4:2e4,2,:));
% stage2_cut=squeeze(stage2_scpRes(1.1e4:2e4,2,:));
% figure;
% subplot(2,2,1);
% 
% imagesc(stage1_cut)
% title('2->3')
% xlabel('freq step')
% ylabel('gate number')
% colorbar
% subplot(2,2,2)
% 
% imagesc(stage2_cut)
% title('2->2')
% xlabel('freq step')
% ylabel('gate number')
% colorbar
% 
% stage1_line=stage1_cut(4e3,:);
% stage2_line=stage2_cut(4e3,:);
% 
% subplot(2,2,3);
% 
% plot(stage1_line)
% title('2->3')
% xlabel('freq step')
% ylabel('Zeeman power [AU]')
% subplot(2,2,4);
% 
% plot(stage2_line)
% title('2->2')
% xlabel('freq step')
% ylabel('Zeeman power [AU]')
% %%
% % figure;
% [fname,fnum,prefix]=getLastpFile;
% runNum = (fnum-repeatNumber*2+1):fnum;
% 
% dat1=[];
% dat2=[];
% for ind=1:2:length(runNum)-1
%     ind
% load(sprintf('D:\\Box Sync\\Lab\\ExpCold\\Measurements\\2019\\09\\15\\150919_%02d.mat',runNum(ind)));
% stage1_res=r.scopeRes{1};
% % subplot(2,1,1)
% dat1(:,:,end+1)=squeeze(stage1_res(1.1e4:3e4,2,:));
% % plot(dat1)
% % hold on
% 
% load(sprintf('D:\\Box Sync\\Lab\\ExpCold\\Measurements\\2019\\09\\15\\150919_%02d.mat',runNum(ind)+1));
% stage2_res=r.scopeRes{1};
% dat2(:,:,end+1)=squeeze(stage2_res(1.1e4:3e4,2,:));
% % subplot(2,1,2)
% % plot(dat2)
% % hold on
% end
% %
% figure;
% subplot(2,2,1)
% d1=squeeze(mean(dat1(:,:,2:end)));
% imagesc(d1)
% colorbar
% ylabel('cycle (freq. num)');
% xlabel('repetition');
% xticks(1:10)
% title('2->3')
% subplot(2,2,2)
% errorbar(mean(d1),std(d1));
% ylabel('power [AU]');
% xlabel('repetition');
% % xticks(1:10)
% % xlim([0 10.5])
% title('2->3')
% 
% subplot(2,2,3)
% d2=squeeze(mean(dat2(:,:,2:end)));
% imagesc(d2)
% colorbar
% title('2->2')
% ylabel('cycle (freq. num)');
% xlabel('repetition');
% % xticks(1:10)
% subplot(2,2,4)
% errorbar(mean(d2),std(d2));
% ylabel('power [AU]');
% xlabel('repetition');
% % xticks(1:10)
% % xlim([0 10.5])
% title('2->2')
% suptitle('Zeeman power variation measurement, no zeeman repump')
