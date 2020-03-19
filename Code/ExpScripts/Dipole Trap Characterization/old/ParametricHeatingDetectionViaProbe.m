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
p.FunctionGen = 1;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
p.probeRampTime = 20;
p.probeRampSpan = 75;
p.probeLockCenter = 400;
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2)
p.looping=1;
p.expName = 'ParametricHeatingDetectionViaProbe';
%%
p.trigPulseTime = 10;
p.repumpTime = 1;
p.MOTReleaseTime = 300;
p.DTParams.TrapTime = 0.5e4;
p.DTParams.repumpLoadingPower = 0.057;
p.DTParams.coolingLoadingPower = 40;
p.DTParams.coolingLoadingDetuning = -40;
p.DTParams.LoadingTime =  15e4;

p.tofTime = 2e3;
p.oscTime = 70e3;
p.loopVars{1} = 'oscFreq';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.loopVals{1} = linspace(1500,2500,1);
AmpFactor = 5.45;
%max power at 10 V (7.4W), 80% at 5.6V (5.9W)
bias = 10;
modulation = (10-5.4)*2;
p.depumpTime = 400;
%
p.s=sqncr();
%setup Rigol for scan
p.s.addBlock({'setRigolModParams','channel',1,'bias',bias/AmpFactor,'modulation',modulation/AmpFactor,'freq',p.oscFreq});
p.s.addBlock({'setRigolBurstMode','channel',1,'mode','gat'});
p.s.addBlock({'setRigolBurstState','channel',1,'state',1});
%load dipole trap
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
%start parametric heeting
p.s.addBlock({'setDigitalChannel','channel','RigolTTL','value','high','duration',p.oscTime});
p.s.addBlock({'pause','duration',p.oscTime});
% p.s.addBlock({'pause','duration',10e3});
%perform tof
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.tofTime});
%measure absorption
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.depumpTime,'value','high'});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'pause','duration',p.depumpTime});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();
%
% figure;
% ax = gca;
% hold(ax,'on')
for ii=1:length(p.loopVals{1})
    clear Upfreq
    clear absor
[Upfreq,UpStartInd,UpEndInd] = getDDSUpRampFreqVec(r.scopeRes{1}(:,1,ii),r.scopeDigRes{1}(:,3,ii),r.scopeDigRes{1}(:,9,ii),75/2,200);
[Downfreq,DownStartInd,DownEndInd] = getDDSDownRampFreqVec(r.scopeRes{1}(:,1,ii),r.scopeDigRes{1}(:,3,ii),r.scopeDigRes{1}(:,9,ii),75/2,200);
data = r.scopeRes{1}(UpStartInd:UpEndInd,5,ii);
bg = fliplr(r.scopeRes{1}(DownStartInd:DownEndInd,5,ii)')';
% bg = (r.scopeRes{1}(DownStartInd:DownEndInd,5,ii));
if length(bg)>length(data)
    bg((length(data)+1):end) = [];
elseif length(bg)<length(data)
    data((length(bg)+1):end) = [];
    Upfreq((length(bg)+1):end) = [];
end
absor{:,ii} = data./bg;
% plot(ax,Upfreq+(ii-1)*20,absor{:,ii})
if ii==1
    initParams = [1,3,1,0,200];
    lower = [0.5,2.5,0.95,0,195];
    upper = [2.5,3.5,1.05,0,205];
else
    initParams = coeffs(:,ii-1);
    lower = initParams-[0.5,0.5,0.05,0,5]';
    upper = initParams+[0.5,0.5,0.05,0,5]';
end
try
    
[fitobject,gof,output,fitFunc] = fitExpLorentzian(Upfreq,absor{:,ii},initParams,lower,upper);
catch e
   error(e)
end
coeffs(:,ii) = coeffvalues(fitobject);
% figure;
% plot(Upfreq,absor{:,ii},'o')
% hold on;
% plot(fitobject)
end
%[OD,Gamma,maxVal,bias,delta0]
figure;
plot(p.loopVals{1},coeffs(1,:),'linewidth',2)
xlabel('Oscillation frequency[Hz]')
ylabel('OD')
title('Parametric heating measurment via probe absorption');
set(gca,'FontSize',16)