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
p.settlingStepN=3;
loadNoise;
p.expName = 'Pumping effitiency vs pumping cycles';
%%
%ramp settings and setup

p.notificationOn = 0;
p.gateTime = 20;
p.gatesPerStep = 10;
p.stepTime = p.gatesPerStep*p.gateTime; %time in us between probe freq steps. Must be below 260. This is 10 gates
if p.stepTime>=260
    error('step time must be <260 us! you asked for %0.0f',p.stepTime)
end
p.probeNDList = [13,3,2];
p.ZeemanNDList = [11];
p.zeemanRepumpND=[7]; %list with values of the ND filters used in the zeeman repump for this measurement
p.zeemanRepumpPower = 0.0056;%0.0056 is p.loopvals{2}(4) in power scan
p.s = sqncr;
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','low'});
p.s.addBlock({p.asyncActions.setZeemanRepumpPower,'value',p.zeemanRepumpPower,'ND',p.zeemanRepumpND});
p.s.runStep;

p.NAverage = 3;
p.loopVals{1} = 1:5:41;
p.loopVars{1} = 'ZeemanPumpCycles';
p.ZeemanPumpCycles = p.INNERLOOPVAR;
[~,max_p,min_p]=calculateAtten(p.ZeemanNDList,'zeemanpump');
p.loopVals{2} = logspace(log10(1.05*min_p),log10(0.95*max_p),7);
p.loopVars{2} = 'zeemanPumpPower';
p.zeemanPumpPower = p.OUTERLOOPVAR;
p.gateNum = 3e3;
p.freqNum = ceil(p.gateNum/p.gatesPerStep); %number of freq steps is the number of gates devided by the number of gates per step
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 120;
p.probeRampSpan22 = 40;
p.probeCenterOffset23=-4;
p.probeCenterOffset22=p.probeCenterOffset23-266;
p.probeDets = linspace(p.probeCenterOffset23-p.probeRampSpan/2,p.probeCenterOffset23+p.probeRampSpan/2,p.freqNum);
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset23;

resetProbeLock([p.probeCenterOffset23-p.probeRampSpan/2,probeFreqToDet(inst.DDS.getFreq(2),8)])
% end
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)
%optical pumping settings and probe power
p.BiasField=-1+p.B0(2);
p.MagneticPulseTime=p.gateNum * (p.gateTime+2) + 30e3 ;
p.repumpTime = 100;
%dipole trap loading params
p.DTParams.MOTLoadTime = 1e6;

p.plotSmooth = 10;
p.smothProbeDets = linspace(min(p.probeDets),max(p.probeDets),round(length(p.probeDets)/p.plotSmooth));
p.s=sqncr();
p.s.addBlock({p.asyncActions.setZeemanPumpPower,'value',p.zeemanPumpPower,'ND',p.ZeemanNDList});
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
ip = [1,3.03,1,0,-4-266];
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
catch 
        warning('analysis phase 2 failed')
end
p.runAutoPlot = 1;
if p.runAutoPlot==0
    return
end
%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
fs = 12;
tfs = 14;
figure;
tl = tiledlayout(3,2);
nexttile
imagesc(1:length(p.loopVals{2}),p.loopVals{1},meanODs23)
title('OD (F2->F''3) vs zeeman pump power and pumping cycles')
set(gca, 'XTick', 1:length(p.loopVals{2}),'XTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{2},'UniformOutput',false))
xlabel('zeeman pump power [\muW]')
ylabel('pumping cycles')
set(gca,'fontsize',fs);
colorbar

nexttile
imagesc(1:length(p.loopVals{2}),p.loopVals{1},meanODs22)
set(gca, 'XTick', 1:length(p.loopVals{2}),'XTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{2},'UniformOutput',false))
xlabel('zeeman pump power [\muW]')
ylabel('pumping cycles')
set(gca,'fontsize',fs);

title('OD (F2->F''2) vs zeeman pump power and pumping cycles')
colorbar
[pe0,mf20] = getPumpingEffitiency(meanODs23./meanODs22,0);
[pe1,mf21] = getPumpingEffitiency(meanODs23./meanODs22,1);
nexttile
imagesc(1:length(p.loopVals{2}),p.loopVals{1},pe0)
set(gca, 'XTick', 1:length(p.loopVals{2}),'XTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{2},'UniformOutput',false))
xlabel('zeeman pump power [\muW]')
ylabel('pumping cycles')
set(gca,'fontsize',fs);
title('pumping efficiency (model 0) vs zeeman pumping power pumping cycles')
colorbar
nexttile
imagesc(1:length(p.loopVals{2}),p.loopVals{1},pe1)
set(gca, 'XTick', 1:length(p.loopVals{2}),'XTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{2},'UniformOutput',false))
xlabel('zeeman pump power [\muW]')
ylabel('pumping cycles')
set(gca,'fontsize',fs);
title('pumping efficiency (model 1) vs zeeman pumping power pumping cycles')
colorbar
pod0 = getPumpedOD(meanODs23,mf20,0);
pod1 = getPumpedOD(meanODs23,mf20,1);
nexttile
imagesc(1:length(p.loopVals{2}),p.loopVals{1},pod0)
set(gca, 'XTick', 1:length(p.loopVals{2}),'XTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{2},'UniformOutput',false))
xlabel('zeeman pump power [\muW]')
ylabel('pumping cycles')
set(gca,'fontsize',fs);
title('Pumped OD (model 0) vs zeeman pumping power pumping cycles')
colorbar
nexttile
imagesc(1:length(p.loopVals{2}),p.loopVals{1},pod1)
set(gca, 'XTick', 1:length(p.loopVals{2}),'XTickLabel',arrayfun(@(x) sprintf('%.2f',1e3*x),p.loopVals{2},'UniformOutput',false))
xlabel('zeeman pump power [\muW]')
ylabel('pumping cycles')
set(gca,'fontsize',fs);
title('Pumped OD (model 1) vs zeeman pumping power pumping cycles')
colorbar



