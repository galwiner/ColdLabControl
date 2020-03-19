clear all;
instrreset;
global p;
global r;
global inst;
initp;
p.hasTTresults = 1;
p.ttDumpMeasurement = 1;
p.expName = 'EIT shift low OD';
initinst;
initr;
p.probePower = 2e-11;
loadNoise;
%%
p.s = sqncr;
p.s.addBlock({'setProbePower','value',p.probePower,'duration',0});
p.s.addBlock({'Load MOT'});
p.s.runStep;
p.gateNum = 2e4;
% p.DTParams.TrapTime = 1e6;
p.DTParams.TrapTime = 1;
% p.DTParams.MOTLoadTime = 0.75e6;
p.NInner = 40;
p.loopVals{1} = linspace(-16,4,p.NInner);
p.loopVars{1} = 'probeDet';
p.probeDet = p.INNERLOOPVAR;
p.NAverage = 1;
p.gateTime = 20;
p.preGateNum = 4e3;
p.prePulse480 = 1;
p.MagneticPulseTime=(p.gateNum + p.preGateNum) * (p.gateTime+1) + 5e3+30e3;
p.biasField=-0.5;
p.s = sqncr;
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet,'from',2,'to',3,'multiplier',8});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({'LoadDipoleTrapAndPump'});
if p.prePulse480==1
    p.s.addBlock({'forStart'});
    p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
    p.s.addBlock({'pause','duration',p.gateTime/2});
    p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
    p.s.addBlock({'pause','duration',p.gateTime/2});
    p.s.addBlock({'forEnd','value',p.preGateNum});
else
    p.s.addBlock({'pause','duration',p.preGateNum*p.gateTime});
end
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});

p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %close 480 shutter 
p.s.addBlock({'pause','duration',5e3}); %shutter open delay
p.s.addBlock({'forStart'});
p.s.addBlock({'measureSPCMWith480Control'});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'resetSystem'});
p.s.run;
keepDipoleTrapWarm
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
load(matFileName)
removeDoubleCycle;
fixMissingCycle
sectionsList = {1:500:(p.gateNum+500)};
sectionByList = string('gate');
sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,p.NAverage);
plotList = sectionsList{1}(2:end-1);

figure;
imagesc(plotList,p.loopVals{1},sectionedRes.phot_per_cycle)
% if length(phot_per_cycle)<length(p.loopVals{1})
% phot_per_cycle(end+1:length(p.loopVals{1})) = nan;
% elseif length(phot_per_cycle)>length(p.loopVals{1})
%     phot_per_cycle(length(p.loopVals{1})+1:end) = [];
% end
% figure;
% plot(p.loopVals{1},(phot_per_cycle/p.gateNum/p.gateTime*2-p.noiseRate)/(p.bgRate-p.noiseRate))
