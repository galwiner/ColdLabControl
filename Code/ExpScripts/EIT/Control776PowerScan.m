clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr

p.probeRampTime = 40;
p.probeRampSpan = 75;
p.probeLockCenter = 400;
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2)
p.looping=1;
p.expName = 'Control776PowerScan';
%%
p.NAverage = 1;
p.repumpTime = 1;
p.MOTReleaseTime = 300;
p.tofTime = 0.6e3;
p.DTParams.TrapTime = 4e4;
p.DepumpTime= 1e3;
p.probeDet =0;
p.loopVals{1} = linspace(1e-3,1e-3,1);
p.loopVars{1} = 'controlPower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.probeNDList=3;
p.Control776NDList = 7;
p.s=sqncr();
p.s.addBlock({'set776ControlPower','value',p.controlPower,'duration',0});
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
p.s.addBlock({'setProbePower','duration',0,'value',4e-6,'channel','PRBVVAN'})
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
%repump
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high','description','REPUMP OFF'});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','REPUMP OFF'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',500});
%tof
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.tofTime});
%measure
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});

p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','value','high','duration',0});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'TrigScope'});
%start scan
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.probeRampTime+50});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
% %start depump
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.DepumpTime});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',20});
%scan back
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
% p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','value','high','duration',0});
p.s.addBlock({'pause','duration',p.probeRampTime+50});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'pause','duration',4.1e3});
p.s.run();
%
[freq,startInds,endInds] = getDDSTriangleRampFreqVec(r.scopeRes{1}(:,1),r.scopeDigRes{1}(:,9),p.probeRampSpan,p.probeDet);
data = squeeze(r.scopeRes{1}(startInds(1):endInds(1),5,1,:,:));
meanData = squeeze(mean((r.scopeRes{1}(startInds(1):endInds(1),5,1,:,:)),5));
bg = flip(squeeze(r.scopeRes{1}(startInds(2):endInds(2),5,1,:,:)),1);
abs = data./bg;
figure;
plot(freq,abs)
%%
data = squeeze(r.scopeRes{1}(startInds(1):endInds(1),5,1,:,:));
meanData = squeeze(mean((r.scopeRes{1}(startInds(1):endInds(1),5,1,:,:)),5));
bg = flip(squeeze(r.scopeRes{1}(startInds(2):endInds(2),5,1,:,:)),1);
abs = data./bg;
meanBg = fliplr(meanBg')';
meanAbs = meanData./meanBg;
figure;
plotlist = [2,3,4,5,7,10,15];
gca
hold on
for ii = 1:length(plotlist)
plot(freq,meanAbs(:,plotlist(ii)))
legendList{ii} = sprintf('%0.2f uW',p.loopVals{1}(plotlist(ii))*1e3);
end
xlabel('Probe Detuning [MHz]')
ylabel('Transmission')
legend(legendList,'location','southeast')
title('5P_{3/2} -> 5D_{5/2} EIT vs Control Power')
set(gca,'fontsize',22)