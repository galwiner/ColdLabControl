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
p.expName = 'Pumping effitiency vs magnetic field';
%%
%ramp settings and setup

p.notificationOn = 0;
p.gateTime = 20;
p.gatesPerStep = 3;
p.stepTime = p.gatesPerStep*p.gateTime; %time in us between probe freq steps. Must be below 260. This is 10 gates
if p.stepTime>=260
    error('step time must be <260 us! you asked for %0.0f',p.stepTime)
end
p.probeNDList = [13,3,2];
p.ZeemanNDList = [1];
p.zeemanRepumpND=[7]; %list with values of the ND filters used in the zeeman repump for this measurement
p.zeemanPumpPower = 0.00158; %0.0046 is p.loopvals{1}(5) in power scan
p.zeemanRepumpPower = 0.00269;%0.0095 is p.loopvals{2}(5) in power scan
p.s = sqncr;
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','low'});
p.s.addBlock({p.asyncActions.setZeemanPumpPower,'value',p.zeemanPumpPower,'ND',p.ZeemanNDList});
p.s.addBlock({p.asyncActions.setZeemanRepumpPower,'value',p.zeemanRepumpPower,'ND',p.zeemanRepumpND});
p.s.runStep;
p.ZeemanPumpCycles=20;
p.NAverage = 5;
p.loopVals{1} =linspace(-0.3,-0.1,10)+p.B0(2);
% p.loopVals{1} =-0.2+p.B0(2);
p.loopVars{1} = 'ScannedBiasField';
p.ScannedBiasField = p.INNERLOOPVAR;
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
% p.BiasField=-0.2+p.B0(2);
p.MagneticPulseTime=p.gateNum * (p.gateTime+2) + 30e3 ;
p.repumpTime = 100;
%dipole trap loading params
p.DTParams.MOTLoadTime = 0.25e6;

p.plotSmooth = 10;
p.smothProbeDets = linspace(min(p.probeDets),max(p.probeDets),round(length(p.probeDets)/p.plotSmooth));
p.s=sqncr();
p.s.addBlock({p.asyncActions.configDoubleBPulse,'direction','y','scannedVal',p.ScannedBiasField});
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
    if all(trans23(ii,:)<0)
        coefs23(:,ii) = nan(5,1);
        continue
    end
    [fos23{end+1},gof] = fitExpLorentzian(p.smothProbeDets,trans23(ii,:),ip,lp,up);
    coefs23(:,ii) = coeffvalues(fos23{end});
end
ODs23 = coefs23(1,:);
% ODs23(end+1) = nan;
% ODs23(7:end) = ODs23(6:end-1); 
% ODs23(6) = nan;
% ODs23(end+1) = nan;

try 
ODMat23 = reshape(ODs23,[p.NAverage,length(p.loopVals{1})]);  
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
        if all(trans22(ii,:)<0)
        coefs22(:,ii) = nan(5,1);
        continue
    end
    [fos22{end+1},gof] = fitExpLorentzian(p.smothProbeDets22,trans22(ii,:),ip,lp,up);
    coefs22(:,ii) = coeffvalues(fos22{end});
end
ODs22 = coefs22(1,:);
try
ODMat22 = reshape(ODs22,[p.NAverage,length(p.loopVals{1})]);
meanODs22 = squeeze(nanmean(ODMat22,1));
ODstd22 = squeeze(nanstd(ODMat22,[],1));
% figure;

figure;
subplot(3,2,1);
errorbar(p.loopVals{1},meanODs23,ODstd23)
title('OD (F2->F''3) vs zeeman pump cycls (each cycle is 10 \mus)')
ylabel('OD')
xlabel('Pumping cycles')

subplot(3,2,2);
errorbar(p.loopVals{1},meanODs22,ODstd22)
ylabel('OD')
xlabel('Pumping cycles')
title('OD (F2->F''2) vs zeeman pump and repump power')
[pe0,mf20] = getPumpingEffitiency(meanODs23./meanODs22,0);
[pe1,mf21] = getPumpingEffitiency(meanODs23./meanODs22,1);

subplot(3,2,3);
plot(p.loopVals{1},pe0)
ylabel('Pumping effitiency')
xlabel('Pumping cycles')
title('pumping efficiency (model 0) vs zeeman pump and repump power')
set(gca,'fontsize',12)
subplot(3,2,4);
plot(p.loopVals{1},pe1)
ylabel('Pumping effitiency')
xlabel('Pumping cycles')
title('pumping efficiency (model 1) vs zeeman pump and repump power')
set(gca,'fontsize',12)
pod0 = getPumpedOD(meanODs23,mf20,0);
pod1 = getPumpedOD(meanODs23,mf20,1);

subplot(3,2,5);
plot(p.loopVals{1},pod0)
ylabel('Pumped OD')
xlabel('Pumping cycles')
title('Pumped OD (model 0) vs zeeman pump and repump power')
set(gca,'fontsize',12)
subplot(3,2,6);
plot(p.loopVals{1},pod1)
ylabel('Pumped OD')
xlabel('Pumping cycles')
title('Pumped OD (model 1) vs zeeman pump and repump power')
set(gca,'fontsize',12)
catch 
        warning('analysis phase 2 failed')
end


