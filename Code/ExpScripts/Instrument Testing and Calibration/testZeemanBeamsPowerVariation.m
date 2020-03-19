clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasTTresults = 0;
p.ttDumpMeasurement = 0;
p.hasScopResults = 1;
p.chanList = [1 ,2];
initinst
initr
inst.scopes{1} = keysightScope('10.10.10.19',[],'ip');
p.probePower=3e-9; %in mW6
loadNoise;
p.expName = 'test zeeman beams power variation';
%%
%ramp settings and setup
p.expName = 'FastModeSpectroscopyTest';
p.gateTime = 20;
p.gatesPerStep = 10;
p.stepTime = p.gatesPerStep*p.gateTime; %time in us between probe freq steps. Must be below 260. This is 10 gates
if p.stepTime>=260
    error('step time must be <260 us! you asked for %0.0f',p.stepTime)
end
p.NAverage = 50;
p.loopVals{1} = linspace(3.65e-6,7e-4,1);
p.loopVars{1} = 'zeemanPumpPower';
p.zeemanPumpPower = p.INNERLOOPVAR;

p.loopVals{2} = linspace(2.26e-4,2e-2,1);
p.loopVars{2} = 'zeemanRepumpPower';
p.zeemanRepumpPower = p.OUTERLOOPVAR;
p.gateNum = 3e3;
p.freqNum = ceil(p.gateNum/p.gatesPerStep); %number of freq steps is the number of gates devided by the number of gates per step
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 80;
p.probeCenterOffset23=-4;
p.probeCenterOffset22=p.probeCenterOffset23-266;
p.probeDets = linspace(p.probeCenterOffset23-p.probeRampSpan/2,p.probeCenterOffset23+p.probeRampSpan/2,p.freqNum);
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset23;
%reset probe lock
if inst.DDS.getFreq(2)~=0
%     resetProbeLock([p.probeCenterOffset23-p.probeRampSpan/2,p.probeCenterOffset22-p.probeRampSpan/2])
end
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)
%optical pumping settings and probe power
p.BiasField=-0.5;
p.probeNDList = [13,3,2];
p.ZeemanNDList = [1,7,9];
p.zeemanRepumpND=[10,8,12]; %list with values of the ND filters used in the zeeman repump for this measurement
p.MagneticPulseTime=p.gateNum * (p.gateTime+2) + 30e3 ;
p.repumpTime = 100;
%dipole trap loading params
p.DTParams.MOTLoadTime = 2e6;
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
pause(10)
% resetProbeLock([p.probeCenterOffset22-p.probeRampSpan/2,p.probeCenterOffset23-p.probeRampSpan/2])
% inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)
p.s.run;



%%

measInds = [11540,21910,32010,42220,52400,62680,72570,82750;16520,26710,36880,47060,57230,67410,77350,87750];
data2mean = nan(size(r.scopeRes{1}(:,2:3,:)));
for ii = 1:size(measInds,2)
   data2mean(measInds(1,ii):measInds(2,ii),:,:) =  r.scopeRes{1}(measInds(1,ii):measInds(2,ii),2:3,:);
end
meanSigs = squeeze(nanmean(data2mean,1));
% meanSigs(:,37) = nan;
figure;
yyaxis left
plot(meanSigs(1,:))
yyaxis right
plot(meanSigs(2,:))
