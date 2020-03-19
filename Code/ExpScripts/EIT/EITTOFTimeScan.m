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
p.probeRampTime = 100;
p.probeRampSpan = 75;
% p.probeLockCenter = probeDetToFreq(0,1);
p.probeLockCenter = 400;
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2)
% p.probeRampTime = 1e4;
% p.probeRampSpan = 100;
% % p.probeLockCenter = probeDetToFreq(0,1);
% p.probeLockCenter = 200;
% inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,1)
p.looping=1;
p.expName = 'EITTOFTimeScan';
%%
% inst.DDS.setFreq(1,63,0,0);
% pause(0.3)
p.repumpTime = 1;
p.MOTReleaseTime = 300;
p.DTParams.TrapTime = 5e4;
% p.NAverage = 3;
% p.loopVals{1} = [linspace(0.045,0.055,5),linspace(0.065,0.1,5)];
% p.loopVars{1} = 'DTParams.repumpLoadingPower';
% p.DTParams.repumpLoadingPower = p.INNERLOOPVAR;
p.loopVals{1} = linspace(1,500,10);
p.loopVars{1}='TOFTime';
% p.TOFTime = 1;
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.DTParams.repumpLoadingPower = 0.057;
p.DTParams.coolingLoadingPower = 40;
p.DTParams.coolingLoadingDetuning = -40;
p.DTParams.LoadingTime =  15e4;
p.s=sqncr();
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

p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',p.probeRampTime*2+50+20,'value','high'});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',p.probeRampTime+50,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',p.probeRampTime+50,'value','high'});
% p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.probeRampTime*2+50});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();
%
% figure;
% for ii= 1:10
% subplot(5,2,ii)
% plot(squeeze(r.scopeRes{1}(:,5,1,ii,:)))
% end
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
% plot(ax1,Upfreq,UpData+(ii-1)*0.007,'linewidth',2)
% plot(ax2,fliplr(Downfreq),DownData+(ii-1)*0.007,'linewidth',2)
plot(ax1,Upfreq*2,UpData,'linewidth',2)
plot(ax2,fliplr(Downfreq*2),DownData,'linewidth',2)
end