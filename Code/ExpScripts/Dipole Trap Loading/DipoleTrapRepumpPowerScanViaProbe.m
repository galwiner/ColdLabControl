clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);
% s=sqncr();
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.picsPerStep = 1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.probeRampTime = 20;
p.probeRampSpan = 75;
p.probeLockCenter = 400;
initinst
initr
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2)
p.expName = 'DipoleTrapRepumpPowerScanViaProbe';
%%
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
% p.repumpLoadingPower = 18;
p.DTParams.LoadingTime = 1e5;
p.DTParams.TrapTime = 2e4;
% p.DTParams.repumpLoadingPower = 0.05;
p.DTParams.coolingLoadingPower = 30;
p.DTParams.coolingLoadingDetuning = -20;
p.DepumpTime = 400;

p.loopVals{1} = linspace(0.03,0.06,20);
p.loopVars{1} = 'DTParams.repumpLoadingPower';
p.DTParams.repumpLoadingPower = p.INNERLOOPVAR;

p.s=sqncr();
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.DepumpTime});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
p.s.addBlock({'GenPause','duration',1e5});
p.s.run
%%
figure
jj = 1;
ax = gca;
hold(ax,'on')
for ii =1:length(p.loopVals{1}) 
[Upfreq,UpStartInd,UpEndInd] = getDDSUpRampFreqVec(r.scopeRes{1}(:,1,1,ii,jj),r.scopeDigRes{1}(:,3,1,ii,jj),r.scopeDigRes{1}(:,9,1,ii,jj),75/2,200);
[Downfreq,DownStartInd,DownEndInd] = getDDSDownRampFreqVec(r.scopeRes{1}(:,1,1,ii,jj),r.scopeDigRes{1}(:,3,1,ii,jj),r.scopeDigRes{1}(:,9,1,ii,jj),75/2,200);
data = r.scopeRes{1}(UpStartInd:UpEndInd,5,1,ii,jj);
% data = smooth(data,100);
bg = fliplr(r.scopeRes{1}(DownStartInd:DownEndInd,5,1,ii,jj)')';
% bg = smooth(bg,100);
% bg = (r.scopeRes{1}(DownStartInd:DownEndInd,5,ii));
if length(bg)>length(data)
    bg((length(data)+1):end) = [];
elseif length(bg)<length(data)
    data((length(bg)+1):end) = [];
    Upfreq((length(bg)+1):end) = [];
end
absor{:,ii} = data./bg;
plot(Upfreq+(ii-1)*20,absor{:,ii})
end





