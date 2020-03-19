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
%%
%ramp settings and setup
% initp
p.runSettlingLoop = 0;
p.hasTTresults = 1;
p.ttDumpMeasurement = 1;
p.expName = 'FastModeSpectroscopySymmetrizer';
p.gateTime = 20;
p.gatesPerStep = 3;
p.stepTime = p.gatesPerStep*p.gateTime; %time in us between probe freq steps. Must be below 260. This is 10 gates
if p.stepTime>=260
    error('step time must be <260 us! you asked for %0.0f',p.stepTime)
end
p.NAverage = 1;
p.gateNum = 3e3;
p.freqNum = ceil(p.gateNum/p.gatesPerStep); %number of freq steps is the number of gates devided by the number of gates per step
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 80;
p.probeCenterOffset=-4;
p.probeDets = linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,1,[],p.freqNum)
%optical pumping settings and probe power
p.probeNDList = [13,3,2];
p.s = sqncr;
p.s.addBlock({p.asyncActions.setZeemanPumpPower,'value',p.zeemanPumpPower,'ND',p.ZeemanNDList});
p.s.addBlock({p.asyncActions.setZeemanRepumpPower,'value',p.zeemanRepumpPower,'ND',p.zeemanRepumpND});
p.s.runStep;
p.MagneticPulseTime=p.gateNum * (p.gateTime+2) + 30e3 ;
%dipole trap loading params
p.DTParams.MOTLoadTime = 1.5e6;
figure
for ii = 1:100
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','low'});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({p.compoundActions.LoadDipoleTrapAndPump});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time
%start freq scan for up 
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','high'});
%measure up
p.s.addBlock({'forStart'});
p.s.addBlock({p.compoundActions.measureSPCMWith480Control});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'pause','duration',p.gateNum*p.gateTime});
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.PurpleDTSwitch,'value','low','duration',0})
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.BlueDTSwitch,'value','low','duration',0})
%reload
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
% p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','low'});
p.s.addBlock({'pause','duration',5e3}); %additional trapping time
p.s.addBlock({p.compoundActions.LoadDipoleTrapAndPump});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trapping time
%start freq scan for down 
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','low'});
%measure down
p.s.addBlock({'forStart'});
p.s.addBlock({p.compoundActions.measureSPCMWith480Control});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'pause','duration',p.gateNum*p.gateTime});

%reset
p.s.addBlock({p.compoundActions.resetSystemNoReload});
% p.s.addBlock({p.compoundActions.resetSystem});
p.s.run;

p.plotSmooth = 10;

p.smothProbeDets = linspace(min(p.probeDets),max(p.probeDets),round(length(p.probeDets)/p.plotSmooth));

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName,datMat]=ttDumpProcessing(r.fileNames);

load(matFileName)

sectionsList = {1:p.gatesPerStep*p.plotSmooth:(p.gateNum+1)};
sectionByList = string('gate');
sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,1);

% imagesc(p.loopVals{1},p.smothProbeDets,sectionedRes.phot_per_cycle')
% imagesc(1:p.NAverage,p.smothProbeDets,sectionedRes.phot_per_cycle')
trans = (sectionedRes.phot_per_cycle./(p.gatesPerStep*p.plotSmooth*p.gateTime/2)-p.noiseRate)/(p.bgRate-p.noiseRate);
% figure
subplot(4,4,1);
plot(p.smothProbeDets,trans(1,:))
hold on
plot(p.smothProbeDets,fliplr(trans(2,:)))
hold off
subplot(4,4,[5,6,9,10,13,14]);
plot(p.smothProbeDets,(trans(1,:)+fliplr(trans(2,:)))/2)
title('symmetrical')
subplot(4,4,[7,8,11,12,15,16]);
plot(p.smothProbeDets,(trans(1,:)-fliplr(trans(2,:)))/2)
title('anti-symmetrical')
% subplot(4,4,1);
% plot(p.smothProbeDets,trans(:,:))
% 
% subplot(4,4,[5,6,9,10,13,14]);
% plot(p.smothProbeDets,(trans(1,:)+(trans(2,:)))/2)
% title('symmetrical')
% subplot(4,4,[7,8,11,12,15,16]);
% plot(p.smothProbeDets,(trans(1,:)-(trans(2,:)))/2)
% title('anti-symmetrical')
end

% figure
% subplot(4,4,1);
% plot(fliplr(p.smothProbeDets),trans(1,:))
% hold on
% plot(fliplr(p.smothProbeDets),fliplr(trans(2,:)))
% hold off
% subplot(4,4,[5,6,9,10,13,14]);
% plot(p.smothProbeDets,(trans(1,:)+fliplr(trans(2,:)))/2)
% title('symmetrical')
% subplot(4,4,[7,8,11,12,15,16]);
% plot(p.smothProbeDets,(trans(1,:)-fliplr(trans(2,:)))/2)
% title('anti-symmetrical')

% figure
% subplot(4,4,1);
% plot(p.smothProbeDets,trans(:,:))
% 
% subplot(4,4,[5,6,9,10,13,14]);
% plot(p.smothProbeDets,(trans(1,:)+(trans(2,:)))/2)
% title('symmetrical')
% subplot(4,4,[7,8,11,12,15,16]);
% plot(p.smothProbeDets,(trans(1,:)-(trans(2,:)))/2)
% title('anti-symmetrical')
