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
% fclose(inst.DDS.s)
% SHU2_initial_2016(1,0,1)
% DRG_LAB_2(100,80,4e-6,4e-6,10000,10000)
p.probeRampTime = 400;
p.probeRampSpan = 75;
% p.probeLockCenter = probeDetToFreq(0,1);
p.probeLockCenter = 400;
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2)
p.looping=1;
% p.expName = 'ProbeAOMScanOnDipoleTrap';
p.expName = 'ProbeAOMScanOnDipoleTrap';
%%
% inst.DDS.setFreq(1,339,0,0);
p.repumpTime = 1;
p.MOTReleaseTime = 300;
p.DTParams.TrapTime = 2e4;
p.DepumpTime= 400;
% p.loopVals{1} = [linspace(0.045,0.055,5),linspace(0.065,0.1,5)];
% p.loopVars{1} = 'DTParams.repumpLoadingPower';
% p.DTParams.repumpLoadingPower = p.INNERLOOPVAR;
p.tofTime = 1;
p.probeNDList=[3,5];
p.NAverage = 1;
p.DTParams.repumpLoadingPower = 0.057;
p.DTParams.coolingLoadingPower = 40;
p.DTParams.coolingLoadingDetuning = -40;
p.DTParams.LoadingTime =  15e4;
p.s=sqncr();
p.s.addBlock({'setProbePower','duration',0,'value',3e-6,'channel','PRBVVAN'})
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high','description','REPUMP OFF'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',100});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','REPUMP OFF'});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','REPUMP OFF'});
%turn on probe and control and wait a bit (20 us) for tranziant to settle
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'TrigScope'});
%start scan
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.probeRampTime+50});
%start depump
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.DepumpTime});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',20});
%scan back
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.probeRampTime+50});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
% p.s.addBlock({'pause','duration',4.1e3});
p.s.run();

data = squeeze(r.scopeRes{1}(:,5,:));
meanData = mean(data,2);

figure
plot(meanData)

[Upfreq,UpStartInd,UpEndInd] = getDDSUpRampFreqVec(r.scopeRes{1}(:,1,1,1,1),r.scopeDigRes{1}(:,3,1,1,1),r.scopeDigRes{1}(:,9,1,1,1),75/2,200);
[Downfreq,DownStartInd,DownEndInd] = getDDSDownRampFreqVec(r.scopeRes{1}(:,1,1,1,1),r.scopeDigRes{1}(:,3,1,1,1),r.scopeDigRes{1}(:,9,1,1,1),75/2,200);
data2 = meanData(UpStartInd:UpEndInd);
% data = smooth(data,100);
bg = fliplr(meanData(DownStartInd:DownEndInd)')';
% bg = smooth(bg,100);
% bg = (r.scopeRes{1}(DownStartInd:DownEndInd,5,ii));
if length(bg)>length(data2)
    bg((length(data2)+1):end) = [];
elseif length(bg)<length(data2)
    data2((length(bg)+1):end) = [];
    Upfreq((length(bg)+1):end) = [];
end
absor = data2./bg;
plot(Upfreq-200,absor)
xlabel('probe Detuning [MHz]')
ylabel('Transmission')
set(gca,'fontsize',16)