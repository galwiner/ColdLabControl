clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasTTresults = 1;
p.ttDumpMeasurement = 1;
initinst
initr
p.probePower=3e-9; %in mW6
loadNoise;
repumpLoadingPower_orig = p.DTParams.repumpLoadingPower;
coolingLoadingDetuning_orig = p.DTParams.coolingLoadingDetuning;

%%
%ramp settings and setup
lowOD = 1;
midOD=0;
if lowOD
p.DTParams.repumpLoadingPower = 0.04;
p.DTParams.coolingLoadingDetuning = -45;
p.probeRampSpan = 20;
elseif midOD
p.DTParams.repumpLoadingPower = 0.045;
p.DTParams.coolingLoadingDetuning = -35;
p.probeRampSpan = 20;
    else
    p.DTParams.repumpLoadingPower = repumpLoadingPower_orig;
    p.DTParams.coolingLoadingDetuning = coolingLoadingDetuning_orig;
end
p.runSettlingLoop = 0;
p.hasTTresults = 1;
p.ttDumpMeasurement = 1;
p.expName = 'FastModeSpectroscopy';
p.gateTime = 20;
p.gatesPerStep = 10;
p.stepTime = p.gatesPerStep*p.gateTime; %time in us between probe freq steps. Must be below 260. This is 10 gates
if p.stepTime>=260
    error('step time must be <260 us! you asked for %0.0f',p.stepTime)
end
p.NAverage = 1;
% p.loopVals{1} = linspace(50,400,15);
% p.loopVars{1} = 'DTParams.secondStageCoolingPower';
% p.DTParams.secondStageCoolingPower = p.INNERLOOPVAR ;
p.MOTReloadTime =1;
p.resetSysGenPause=1;
p.gateNum = 1e4;
p.freqNum = ceil(p.gateNum/p.gatesPerStep); %number of freq steps is the number of gates devided by the number of gates per step
p.probeRampTime = p.stepTime*p.freqNum;
if ~(lowOD || midOD)
p.probeRampSpan = 80;
end
p.probeCenterOffset=-4;
p.probeDets = linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)
%optical pumping settings and probe power
% p.BiasField=-0.1+p.B0(2);
p.probeNDList = [13,3,2];
% p.ZeemanNDList = [1];
% p.zeemanRepumpND=[7]; %list with values of the ND filters used in the zeeman repump for this measurement
% p.zeemanPumpPower=4.6e-04;
% p.zeemanRepumpPower=0.0095;
p.MagneticPulseTime=p.gateNum * (p.gateTime+2) + 30e3 ;
p.s = sqncr;
p.s.addBlock({p.asyncActions.setZeemanPumpPower,'value',p.zeemanPumpPower,'ND',p.ZeemanNDList});
p.s.addBlock({p.asyncActions.setZeemanRepumpPower,'value',p.zeemanRepumpPower,'ND',p.zeemanRepumpND});
p.s.addBlock({p.asyncActions.configDoubleBPulse});
p.s.runStep;
%dipole trap loading params
p.DTParams.MOTLoadTime = 0.25e6;
p.DTParams.TrapTime = 1;

p.NAverage = 1;
figure
ax1 = subplot(2,2,1:2);
ax2 = subplot(2,2,3);
ax3 = subplot(2,2,4);
title(ax2,'(T+fliplr(T)) /2')
title(ax3,'(T-fliplr(T)) / 2')
p.plotSmooth = 10;

p.smothProbeDets = linspace(min(p.probeDets),max(p.probeDets),round(length(p.probeDets)/p.plotSmooth));

p1 = plot(ax1,p.smothProbeDets,ones(size(p.smothProbeDets)));
p2 = plot(ax2,p.smothProbeDets,ones(size(p.smothProbeDets)));
p3 = plot(ax3,p.smothProbeDets,ones(size(p.smothProbeDets)));
% profile on
p.loopingRun=1;
p.firstLoopingStep=1;
for ii = 1:100
if ii~=1
    p.firstLoopingStep=0;
end
p.s=sqncr();
% p.s.addBlock({p.asyncActions.setHH,'direction','y','value',p.HHYCurrent})
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

procTmr = tic;

p.smothProbeDets = linspace(min(p.probeDets),max(p.probeDets),round(length(p.probeDets)/p.plotSmooth));

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName,datMat]=ttDumpProcessing(r.fileNames);
% load(matFileName)
% removeDoubleCycle;
% fixMissingCycle
sectionsList = {1:p.gatesPerStep*p.plotSmooth:(p.gateNum+1)};
sectionByList = string('gate');

sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,1);

% imagesc(p.loopVals{1},p.smothProbeDets,sectionedRes.phot_per_cycle')
% imagesc(1:p.NAverage,p.smothProbeDets,sectionedRes.phot_per_cycle')
trans = (sectionedRes.phot_per_cycle./(p.gatesPerStep*p.plotSmooth*p.gateTime/2)-p.noiseRate)/(p.bgRate-p.noiseRate);
procTime = toc(procTmr);
    plotTmr = tic;
    set(p1,'Ydata',trans)
    set(p2,'Ydata',trans+fliplr(trans)/2)
    set(p3,'Ydata',(trans-fliplr(trans))/2)
    plotTime = toc(plotTmr);
end
% profile viewer
