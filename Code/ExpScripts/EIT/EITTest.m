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
p.probeRampTime = 150;
p.probeRampSpan = 20;
p.probeLockCenter = 400;
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2)
p.looping=1;
p.expName = 'EITTest';
%%
% inst.DDS.setFreq(1,62,0,0);
% pause(0.3)
p.repumpTime = 1;
p.MOTReleaseTime = 300;
p.DTParams.TrapTime = 2e4;
p.DTParams.repumpLoadingPower = 0.057;
p.DTParams.coolingLoadingPower = 40;
p.DTParams.coolingLoadingDetuning = -40;
p.DTParams.LoadingTime =  15e4;
p.depumpTime = 400;
p.toftime = 1.3e3;
%
p.s=sqncr();

%load dipole trap
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.toftime});
%measure absorption
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',20});

p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.depumpTime,'value','high'});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'pause','duration',p.depumpTime});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();
%
[Upfreq,UpStartInd,UpEndInd] = getDDSUpRampFreqVec(r.scopeRes{1}(:,1,1),r.scopeDigRes{1}(:,3,1),r.scopeDigRes{1}(:,9,1),p.probeRampSpan/2,p.probeLockCenter/2);
[Downfreq,DownStartInd,DownEndInd] = getDDSDownRampFreqVec(r.scopeRes{1}(:,1,1),r.scopeDigRes{1}(:,3,1),r.scopeDigRes{1}(:,9,1),p.probeRampSpan/2,p.probeLockCenter/2);
data = r.scopeRes{1}(UpStartInd:UpEndInd,5,1);
bg = fliplr(r.scopeRes{1}(DownStartInd:DownEndInd,5,1)')';
if length(bg)>length(data)
    bg((length(data)+1):end) = [];
elseif length(bg)<length(data)
    data((length(bg)+1):end) = [];
    Upfreq((length(bg)+1):end) = [];
end
absor = data./bg;
% plot(ax,Upfreq+(1-1)*20,absor{:,1})
%
figure;
plot(Upfreq,absor)

