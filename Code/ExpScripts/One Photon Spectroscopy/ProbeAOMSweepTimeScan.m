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
p.probeRampSpan = 75;
% p.probeLockCenter = probeDetToFreq(0,1);
p.probeLockCenter = 400;
% inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2)
% p.probeRampTime = 1e4;
% p.probeRampSpan = 100;
% % p.probeLockCenter = probeDetToFreq(0,1);
% p.probeLockCenter = 200;
% inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,1)
p.looping=1;
p.expName = 'ProbeAOMSweepTimeScan';
%%
% inst.DDS.setFreq(1,63,0,0);
% pause(0.3)
p.repumpTime = 1;
p.MOTReleaseTime = 300;
p.DTParams.TrapTime = 2e4;
% p.DTParams.TrapTime = 100;
% p.NAverage = 3;
% p.probeRampTime = 100;
% p.loopVals{1} = [linspace(20,100,5),linspace(200,1000,9)];
p.loopVals{1} = linspace(20,20,1);
p.loopVars{1} = 'probeRampTime';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.loopVals{1} = linspace(1,300,10);
% p.loopVars{1}='TOFTime';
p.TOFTime = 1;
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.DTParams.repumpLoadingPower = 0.057;
p.DTParams.coolingLoadingPower = 40;
p.DTParams.coolingLoadingDetuning = -40;
p.DTParams.LoadingTime =  15e4;
p.s=sqncr();
p.s.addBlock({'SetupDDSSweepCentSpan','channel',4,'center',p.probeLockCenter,'span',p.probeRampSpan,...
    'UpTime',p.probeRampTime,'multiplyer',2});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
% p.s.addBlock({'Load MOT'});
% p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.probeRampTime*2,'value','low','description','COOLING OFF'});
% p.s.addBlock({'pause','duration',p.INNERLOOPVAR});
% p.s.addBlock({'pause','duration',6});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'pause','duration',p.TOFTime});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high','description','REPUMP OFF'});

p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'pause','duration',50});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
% p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',p.probeRampTime+50,'value','high'});
% p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'pause','duration',50});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();
p.s=sqncr();
p.s.addBlock({'SetupDDSSweepCentSpan','channel',4,'center',p.probeLockCenter,'span',p.probeRampSpan,...
    'UpTime',p.probeRampTime,'multiplyer',2});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high','description','REPUMP OFF'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'pause','duration',50});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'pause','duration',50});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();
%%
figure;
subplot(2,1,1)
ax1 = gca;
subplot(2,1,2)
ax2 = gca;
hold(ax1,'on')
hold(ax2,'on')
for ii=1:length(p.loopVals{1})
    clear UpData
    clear DownData
[Upfreq,UpStartInd,UpEndInd] = getDDSUpRampFreqVec(r.scopeRes{1}(:,1,ii),r.scopeDigRes{1}(:,3,ii),r.scopeDigRes{1}(:,9,ii),75/2,200);
[Downfreq,DownStartInd1,DownEndInd1] = getDDSDownRampFreqVec(r.scopeRes{1}(:,1,ii),r.scopeDigRes{1}(:,3,ii),r.scopeDigRes{1}(:,9,ii),75/2,200);
UpData = r.scopeRes{1}(UpStartInd:UpEndInd,5,ii);
DownData = r.scopeRes{1}(DownStartInd1:DownEndInd1,5,ii);
% plot(ax1,Upfreq,UpData+(ii-1)*0.05,'linewidth',2)
% plot(ax2,fliplr(Downfreq),DownData+(ii-1)*0.05,'linewidth',2)
plot(ax1,Upfreq*2,UpData,'linewidth',2)
plot(ax2,fliplr(Downfreq*2),DownData,'linewidth',2)
end