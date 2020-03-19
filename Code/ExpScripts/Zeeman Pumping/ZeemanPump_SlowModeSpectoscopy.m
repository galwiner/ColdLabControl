clear all;
instrreset;
global p;
global r;
global inst;
initp;
p.hasTTresults = 1;
p.ttDumpMeasurement = 1;
p.expName = 'slow mode spectroscopy with zeeman pump power scan';
initinst;
initr;
p.probePower = 3e-9;
loadNoise;
%%
p.s = sqncr;
p.s.addBlock({'setProbePower','value',p.probePower,'duration',0});
p.s.addBlock({'Load MOT'});
p.s.runStep;
p.gateNum = 3e3;
p.gateTime = 20;
% p.DTParams.TrapTime = 1.5e6;
p.NInner = 15;
p.probeOffset = -4;
p.probeSpan = 80;
p.NAverage=1;
p.repumpTime = 100;
p.loopVals{1} = linspace(p.probeOffset-p.probeSpan/2,p.probeOffset+p.probeSpan/2,p.NInner);
p.loopVars{1} = 'probeDet';
p.probeDet = p.INNERLOOPVAR;
p.MagneticPulseTime=(p.gateNum) * (p.gateTime+1) + 5e3+30e3;
p.s = sqncr;
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet,'from',2,'to',3,'multiplier',8});
p.s.addBlock({'LoadDipoleTrapAndPump'});
% p.s.addBlock({'LoadDipoleTrap'});
% 
% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
% p.s.addBlock({'pause','duration',p.repumpTime});

p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','value','high','duration',0});
p.s.addBlock({'pause','duration',5e3}); %shutter open delay

p.s.addBlock({'forStart'});
p.s.addBlock({'measureSPCMOnlyProbe'});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'resetSystem'});
p.s.run;
% keepDipoleTrapWarm
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
load(matFileName)
removeDoubleCycle;
fixMissingCycle
if length(phot_per_cycle)<length(p.loopVals{1})
phot_per_cycle(end+1:length(p.loopVals{1})) = nan;
elseif length(phot_per_cycle)>length(p.loopVals{1})
    phot_per_cycle(length(p.loopVals{1})+1:end) = [];
end
figure;
plot(p.loopVals{1},(phot_per_cycle/p.gateNum/p.gateTime*2-p.noiseRate)/(p.bgRate-p.noiseRate))
