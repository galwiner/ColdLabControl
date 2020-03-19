clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasTTresults = 1;
p.ttDumpMeasurement = 1;
p.hasScopResults = 0;
p.HHYCurrent=-0.085;
p.HHZCurrent=0.035;
p.HHXCurrent=-0.041;
initinst
initr
p.probePower=3e-9; %in mW6
loadNoise;
p.expName = 'OD vs bias field';
%%
%set y bias field, and zeeman powers
p.ZeemanNDList = [11,7];
p.zeemanRepumpND=[1];
p.zeemanPumpPower = 1e-3;
p.zeemanRepumpPower = 1.5e-3;
p.s = sqncr;
p.s.addBlock({p.asyncActions.setZeemanPumpPower,'value',p.zeemanPumpPower,'ND',p.ZeemanNDList});
p.s.addBlock({p.asyncActions.setZeemanRepumpPower,'value',p.zeemanRepumpPower,'ND',p.zeemanRepumpND});
p.s.runStep;

%ramp settings and setup
p.gateTime = 20;
p.gatesPerStep = 10;
p.stepTime = p.gatesPerStep*p.gateTime; %time in us between probe freq steps. Must be below 260. This is 10 gates
if p.stepTime>=260
    error('step time must be <260 us! you asked for %0.0f',p.stepTime)
end
p.NAverage = 5;

p.gateNum = 3e3;
p.freqNum = ceil(p.gateNum/p.gatesPerStep); %number of freq steps is the number of gates devided by the number of gates per step
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 100;
p.probeCenterOffset23=-4;
p.probeDets = linspace(p.probeCenterOffset23-p.probeRampSpan/2,p.probeCenterOffset23+p.probeRampSpan/2,p.freqNum);
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset23;
% chan,center,span,time,multiplyer,symmetric
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)
%optical pumping settings and probe power
p.BiasField=-0.5;
p.probeNDList = [13,3,2];

p.MagneticPulseTime=p.gateNum * (p.gateTime+2) + 30e3 ;
p.repumpTime = 100;
%dipole trap loading params
p.DTParams.MOTLoadTime = 0.25e6;
p.DTParams.TrapTime = 1;
p.plotSmooth = 10;
p.smothProbeDets = linspace(min(p.probeDets),max(p.probeDets),round(length(p.probeDets)/p.plotSmooth));


% loop params

p.loopVals{1} = linspace(-0.12,-0.06,15);
% p.loopVals{1} = linspace(0.01,0.06,15);

p.scanDirection = 'y';
p.loopVars{1} = ['HH' upper(p.scanDirection) 'Current'];
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s=sqncr();
p.s.addBlock({p.asyncActions.setHH,'direction',p.scanDirection,'value',p.(p.loopVars{1})})
p.s.addBlock({p.asyncActions.configDoubleBPulse})
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({p.compoundActions.LoadDipoleTrapAndPump});
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
sectionsList = {1:p.gatesPerStep*p.plotSmooth:(p.gateNum+1)};
sectionByList = string('gate');
sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,1);
trans23 = (sectionedRes.phot_per_cycle./(p.gatesPerStep*p.plotSmooth*p.gateTime/2)-p.noiseRate)/(p.bgRate-p.noiseRate);
ip = [60,3.03,1,0,-4];
lp = [0,3.03,1,0,-inf];
up = [inf,3.03,1,0,inf];
fos23 = {};
coefs23 = zeros(5,size(trans23,1));
r2 = zeros(1,size(trans23,1));
for ii = 1:size(trans23,1)
    [fos23{end+1},gof] = fitExpLorentzian(p.smothProbeDets,trans23(ii,:),ip,lp,up);
    coefs23(:,ii) = coeffvalues(fos23{end});
    r2(ii) = gof.rsquare;
end
ODs23 = coefs23(1,:);
ODMat23 = reshape(ODs23,[p.NAverage,length(p.loopVals{1})]);
meanODs23 = squeeze(nanmean(ODMat23,1));
ODstd23 = squeeze(nanstd(ODMat23,[],1));
figure;
errorbar(p.loopVals{1},meanODs23,ODstd23,'linewidth',2)
xlabel(sprintf('%s bias current[A]',p.scanDirection))
ylabel('OD from fit')
title(sprintf('OD vs bias current in %s',p.scanDirection))
set(gca,'fontsize',14)
