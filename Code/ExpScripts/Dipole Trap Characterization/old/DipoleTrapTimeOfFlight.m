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
p.probeRampTime = 20;
p.probeRampSpan = 75;
p.probeLockCenter = 400;
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2)
p.looping=1;
p.expName = 'DipoleTrapTimeOfFlight';
%%
p.repumpTime = 1;
p.MOTReleaseTime = 300;
% p.DTParams.TrapTime = 2.5e4;
p.TOFTime = 1;
% p.DTParams.repumpLoadingPower = 0.057;
% p.DTParams.coolingLoadingPower = 40;
% p.DTParams.coolingLoadingDetuning = -40;
% p.DTParams.LoadingTime =  15e4;
p.NAverage = 1;
% p.DTParams.LoadingTime = 1e5;
% p.DTParams.TrapTime = 2e4;
% p.DTParams.repumpLoadingPower = 0.057;
% p.DTParams.coolingLoadingPower = 30;
% p.DTParams.coolingLoadingDetuning = -20;
p.DTParams.LoadingTime = 1e5;
p.DTParams.TrapTime = 2e4;
p.DTParams.repumpLoadingPower = 0.044;
p.DTParams.coolingLoadingPower = 55;
p.DTParams.coolingLoadingDetuning = -20;
p.DTParams.LoadingTime =  20e3;
p.trigPulseTime = 10;
p.secondStageTime = 20e3;
p.secondStageCoolingDet = -65;
p.secondStageCoolingPower = 350;
% p.tofTime = 1e3;
p.loopVars{1} = 'tofTime';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.loopVals{1} = linspace(40,1000,15);
p.trigPulseTime = 10;
p.depumpTime = 700;

% p.secondStageCoolingDet = -35;
% p.secondStageCoolingPower = 80;
p.secondStageRepumpPower = 0.05;
% p.secondStageTime = 20e3;
p.secondStageTime = 1;
%
p.s=sqncr();
% %load dipole trap
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
% p.s.addBlock({'LoadDipoleTrap'});
% %perform tof
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'pause','duration',p.tofTime});
% %measure absorption
% p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
% p.s.addBlock({'TrigScope'});
% p.s.addBlock({'pause','duration',20});
% p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
% p.s.addBlock({'pause','duration',p.probeRampTime});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.depumpTime,'value','high'});
% p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
% p.s.addBlock({'setCoolingPower','duration',0,'value',690});
% p.s.addBlock({'pause','duration',p.depumpTime});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
% p.s.addBlock({'pause','duration',20});
% p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
% p.s.addBlock({'pause','duration',p.probeRampTime});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
% p.s.addBlock({'GenPause','duration',1e6});

p.s.addBlock({'Load MOT'});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.DTParams.repumpLoadingPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.DTParams.coolingLoadingDetuning});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.DTParams.coolingLoadingPower});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.DTParams.LoadingTime});

p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.secondStageCoolingDet});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.secondStageCoolingPower});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.secondStageRepumpPower});
p.s.addBlock({'pause','duration',p.secondStageTime})
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setAnalogChannel','channel','CircCoil','duration',0,'value',0});
p.s.addBlock({'pause','duration',p.DTParams.TrapTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'endOfSeqToF'});
p.s.addBlock({'pause','duration',p.tofTime});
% p.s.addBlock({'TakePic'});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',3});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.depumpTime});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();
%%
figure;
for ii=1:length(p.loopVals{1})
    for jj=1:p.NAverage
% for ii=1:1
    clear Upfreq
    clear absor
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
absor{:,ii,jj} = data./bg;
% plot(ax,Upfreq+(ii-1)*20,absor{:,ii})
if ii==1
    initParams = [6,2,1,0,200];
    lower = initParams-[1.5,0.1,0.05,0,5];
    lower(2) = 1.9;
    upper = initParams+[5.5,0.1,0.05,0,5];
    upper(2) = 2.1;
    upper(1) = 100;
else
    initParams = coeffs(:,ii-1,jj);
    lower = initParams-[5,0.5,0.1,0,5]';
    lower(2) = 1.9;
    upper = initParams+[5,0.5,0.1,0,5]';
    upper(2) = 2.1;
    upper(1) = 100;
end
try
[fitobject,gof,output,fitFunc] = fitExpLorentzian(Upfreq,absor{:,ii,jj},initParams,lower,upper);
r2(ii,jj) = gof.rsquare;
catch e
%    error(e.message)
if jj==1
    if ii~=1
    coeffs(:,ii,jj) = coeffs(:,ii-1,jj);
    end
else
    coeffs(:,ii,jj) = coeffs(:,ii,jj-1);
end
continue;
end
coeffs(:,ii,jj) = coeffvalues(fitobject);
% figure;
subplot(5,4,ii)
plot(Upfreq,absor{:,ii},'o')
hold on;
plot(fitobject)
legend('off')
% plot(Upfreq,-log(absor{:,ii}),'o')

    end
end
%[OD,Gamma,maxVal,bias,delta0]

%
figure;
plot((p.loopVals{1}+10),coeffs(1,:)./max(coeffs(1,:)),'lineWidth',2)
ylabel('Dipole Trap OD')
xlabel('Time of Flight [\mus]')
title('DT TOF with 2-stage loading')
set(gca,'fontsize',16)
% meanOD = squeeze(mean(coeffs(1,:,:),3));
% stdOD = squeeze(std(1./coeffs(1,:,:),[],3));
% errorbar(p.loopVals{1}.^2,1./meanOD,stdOD)
% time = p.loopVals{1};
% y = meanOD;
% % linFit = fit(p.loopVals{1}.^2',1./meanOD','poly1');
% fitFunc = @(p1,p2,p3,p4,time) p4./((p1.*time.^4+p2*time.^2+p3).^0.5);
% ft = fittype(fitFunc,'independent','time', 'dependent','y','coefficients',...
%     {'p1','p2','p3','p4'});
% p0 = [1,0,0.05,10];
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
%         opts.StartPoint = p0;
% [fitobject,gof,~] =fit((time*1e-3)',y',ft,opts);
% 
% hold on;
% plot(fitobject)
% xlabel('Oscillation frequency[Hz]')
% ylabel('OD')
% title('Parametric heating measurment via probe absorption');
% set(gca,'FontSize',16)