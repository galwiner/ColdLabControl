clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasTTresults = 1;
p.ttDumpMeasurement = 1;
p.hasScopResults = 0;
initinst
initr
p.probePower=3e-9; %in mW6
p.runSettlingLoop=1;
p.settlingStepN=1;
loadNoise;
p.expName = 'OD vs zeemanPump and zeemanRepump power';
%%
%ramp settings and setup
p.s = sqncr;
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','low'});
p.s.runStep;
p.notificationOn;
p.gateTime = 20;
p.gatesPerStep = 3;
p.stepTime = p.gatesPerStep*p.gateTime; %time in us between probe freq steps. Must be below 260. This is 10 gates
if p.stepTime>=260
    error('step time must be <260 us! you asked for %0.0f',p.stepTime)
end
p.probeNDList = [13,3,2];
p.ZeemanNDList = [1,4];
p.zeemanRepumpND=[7]; %list with values of the ND filters used in the zeeman repump for this measurement
p.ZeemanPumpCycles = 8;
p.NAverage = 3;
% p.loopVals{1} = linspace(0.05,0.8,5)*1e-3;
% p.loopVals{1} = logspace(0.05,0.25,1)*1e-3;
[~,max_p,min_p]=calculateAtten(p.ZeemanNDList,'zeemanpump');
p.loopVals{1} = logspace(log10(1.05*min_p),log10(0.95*max_p),7);

% p.loopVals{1} = 0.05e-3;
p.loopVars{1} = 'zeemanPumpPower';
p.zeemanPumpPower = p.INNERLOOPVAR;

% p.loopVals{2} = (linspace(0.05,8,5)*1e-3);
[~,max_p,min_p]=calculateAtten(p.zeemanRepumpND,'zeemanrepump');
p.loopVals{2} = logspace(log10(1.05*min_p),log10(0.95*max_p),7);
% p.loopVals{2} = 0.2e-3;
p.loopVars{2} = 'zeemanRepumpPower';
p.zeemanRepumpPower = p.OUTERLOOPVAR;
p.gateNum = 3e3;
p.freqNum = ceil(p.gateNum/p.gatesPerStep); %number of freq steps is the number of gates devided by the number of gates per step
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 80;
p.probeRampSpan22 = 40;
p.probeCenterOffset23=-4;
p.probeCenterOffset22=p.probeCenterOffset23-266;
p.probeDets = linspace(p.probeCenterOffset23-p.probeRampSpan/2,p.probeCenterOffset23+p.probeRampSpan/2,p.freqNum);
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset23;
%reset probe lock
% if inst.DDS.getFreq(2)~=0
resetProbeLock([p.probeCenterOffset23-p.probeRampSpan/2,probeFreqToDet(inst.DDS.getFreq(2),8)])
% end
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)
%optical pumping settings and probe power
p.BiasField=-0.5;
p.MagneticPulseTime=p.gateNum * (p.gateTime+2) + 30e3 ;
p.repumpTime = 100;
%dipole trap loading params
p.DTParams.MOTLoadTime = 0.25e6;
p.DTParams.TrapTime = 1;
p.DTParams.coolingLoadingDetuning = -30;
p.plotSmooth = 10;
p.smothProbeDets = linspace(min(p.probeDets),max(p.probeDets),round(length(p.probeDets)/p.plotSmooth));
p.s=sqncr();
p.s.addBlock({p.asyncActions.setZeemanPumpPower,'value',p.zeemanPumpPower,'ND',p.ZeemanNDList});
p.s.addBlock({p.asyncActions.setZeemanRepumpPower,'value',p.zeemanRepumpPower,'ND',p.zeemanRepumpND});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({p.compoundActions.LoadDipoleTrapAndPump});
% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
% p.s.addBlock({'pause','duration',p.repumpTime});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time
%start freq scan 
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','high'});
%measure
p.s.addBlock({'forStart'});
p.s.addBlock({p.compoundActions.measureSPCMWith480Control});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'pause','duration',p.gateNum*p.gateTime});
%reset
p.s.addBlock({p.compoundActions.resetSystem});
p.s.run;
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName,datMat]=ttDumpProcessing(r.fileNames);
load(matFileName)
% removeDoubleCycle;
% fixMissingCycle
sectionsList = {1:p.gatesPerStep*p.plotSmooth:(p.gateNum+1)};
sectionByList = string('gate');
sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,1);
trans23 = (sectionedRes.phot_per_cycle./(p.gatesPerStep*p.plotSmooth*p.gateTime/2)-p.noiseRate)/(p.bgRate-p.noiseRate);
ip = [60,3.03,1,0,-4];
lp = [0,3.03,1,0,-inf];
up = [inf,3.03,1,0,inf];
fos23 = {};
coefs23 = zeros(5,size(trans23,1));
for ii = 1:size(trans23,1)
    [fos23{end+1},gof] = fitExpLorentzian(p.smothProbeDets,trans23(ii,:),ip,lp,up);
    coefs23(:,ii) = coeffvalues(fos23{end});
end
ODs23 = coefs23(1,:);
% ODs23(end+1) = nan;
% ODs23(7:end) = ODs23(6:end-1); 
% ODs23(6) = nan;
% ODs23(end+1) = nan;

try 
ODMat23 = reshape(ODs23,[p.NAverage,length(p.loopVals{1}),length(p.loopVals{2})]);  
meanODs23 = squeeze(nanmean(ODMat23,1));
ODstd23 = squeeze(nanstd(ODMat23,[],1));
figure;
% subplot(3,3,1);
% imagesc(p.loopVals{2}*1e3,p.loopVals{1}*1e3,meanODs23)
uimagesc(p.loopVals{2}*1e3,p.loopVals{1}*1e3,meanODs23)
ylabel('zeeman pump power [\muW]')
xlabel('zeeman repump power [\muW]')
title('OD (F2->F''3) vs zeeman pump and repump power')
colorbar

catch 
        warning('analysis phase 1 failed')
end

%change perobe scan to measure f2->f2
p.probeDets = linspace(p.probeCenterOffset22-p.probeRampSpan22/2,p.probeCenterOffset22+p.probeRampSpan22/2,p.freqNum);
p.smothProbeDets22 = linspace(min(p.probeDets),max(p.probeDets),round(length(p.probeDets)/p.plotSmooth));
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset22;
%reset probe lock
resetProbeLock([p.probeCenterOffset22-p.probeRampSpan22/2,probeFreqToDet(inst.DDS.getFreq(2),8)])
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan22,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)

p.s.run;
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName,datMat]=ttDumpProcessing(r.fileNames);
load(matFileName)
% removeDoubleCycle;
% fixMissingCycle
sectionsList = {1:p.gatesPerStep*p.plotSmooth:(p.gateNum+1)};
sectionByList = string('gate');
sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,1);
trans22 = (sectionedRes.phot_per_cycle./(p.gatesPerStep*p.plotSmooth*p.gateTime/2)-p.noiseRate)/(p.bgRate-p.noiseRate);
ip = [1,3.03,1,0,-4+p.probeCenterOffset22];
lp = [0,3.03,1,0,-inf];
up = [inf,3.03,1,0,inf];
fos22 = {};
coefs22 = zeros(5,size(trans22,1));
for ii = 1:size(trans22,1)
    [fos22{end+1},gof] = fitExpLorentzian(p.smothProbeDets22,trans22(ii,:),ip,lp,up);
    coefs22(:,ii) = coeffvalues(fos22{end});
end
ODs22 = coefs22(1,:);
try
ODMat22 = reshape(ODs22,[p.NAverage,length(p.loopVals{1}),length(p.loopVals{2})]);
meanODs22 = squeeze(nanmean(ODMat22,1));
ODstd22 = squeeze(nanstd(ODMat22,[],1));
% figure;

figure;
subplot(3,2,1);
imagesc(meanODs23)
title('OD (F2->F''3) vs zeeman pump and repump power')
set(gca, 'XTick', 1:length(p.loopVals{2}),'XTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{2},'UniformOutput',false))
set(gca, 'YTick', 1:length(p.loopVals{1}),'YTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{1},'UniformOutput',false))
ylabel('zeeman pump power [\muW]')
xlabel('zeeman repump power [\muW]')

colorbar

subplot(3,2,2);
imagesc(meanODs22)
set(gca, 'XTick', 1:length(p.loopVals{2}),'XTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{2},'UniformOutput',false))
set(gca, 'YTick', 1:length(p.loopVals{1}),'YTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{1},'UniformOutput',false))
ylabel('zeeman pump power [\muW]')
xlabel('zeeman repump power [\muW]')

title('OD (F2->F''2) vs zeeman pump and repump power')
colorbar
[pe0,mf20] = getPumpingEffitiency(meanODs23./meanODs22,0);
[pe1,mf21] = getPumpingEffitiency(meanODs23./meanODs22,1);
% figure;
% nexttile
subplot(3,2,3);
imagesc(pe0)
set(gca, 'XTick', 1:length(p.loopVals{2}),'XTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{2},'UniformOutput',false))
set(gca, 'YTick', 1:length(p.loopVals{1}),'YTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{1},'UniformOutput',false))
ylabel('zeeman pump power [\muW]')
xlabel('zeeman repump power [\muW]')
title('pumping efficiency (model 0) vs zeeman pump and repump power')
set(gca,'fontsize',12)
colorbar
% nexttile
subplot(3,2,4);
imagesc(pe1)
set(gca, 'XTick', 1:length(p.loopVals{2}),'XTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{2},'UniformOutput',false))
set(gca, 'YTick', 1:length(p.loopVals{1}),'YTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{1},'UniformOutput',false))
ylabel('zeeman pump power [\muW]')
xlabel('zeeman repump power [\muW]')
title('pumping efficiency (model 1) vs zeeman pump and repump power')
colorbar
set(gca,'fontsize',12)
pod0 = getPumpedOD(meanODs23,mf20,0);
pod1 = getPumpedOD(meanODs23,mf20,1);
% figure;
% nexttile
subplot(3,2,5);
imagesc(pod0)
set(gca, 'XTick', 1:length(p.loopVals{2}),'XTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{2},'UniformOutput',false))
set(gca, 'YTick', 1:length(p.loopVals{1}),'YTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{1},'UniformOutput',false))

ylabel('zeeman pump power [\muW]')
xlabel('zeeman repump power [\muW]')
title('Pumped OD (model 0) vs zeeman pump and repump power')
set(gca,'fontsize',12)


colorbar
% nexttile
subplot(3,2,6);

imagesc(pod1)
set(gca, 'XTick', 1:length(p.loopVals{2}),'XTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{2},'UniformOutput',false))
set(gca, 'YTick', 1:length(p.loopVals{1}),'YTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{1},'UniformOutput',false))
ylabel('zeeman pump power [\muW]')
xlabel('zeeman repump power [\muW]')
title('Pumped OD (model 1) vs zeeman pump and repump power')
colorbar
set(gca,'fontsize',12)


%
catch 
        warning('analysis phase 2 failed')
end

% figure;
% subplot(1,2,1)
% imagesc(trans23')
% subplot(1,2,2)
% imagesc(trans22')

% figure;
% yyaxis left
% plot(ODs22,'-o','LineWidth',3);
% yyaxis right
% plot(ODs23,'-o','LineWidth',3);
% legend({'2->2','2->3'})
% title(sprintf('%0.1f S loading time',p.DTParams.MOTLoadTime*1e-6))
