%fast mode spectroscopy on a cold cloud, in live camera mode
clear all
global p

global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
% p.cameraParams{1}.E2ExposureTime = 20;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.picsPerStep = 1;
% p.HHXCurrent = -0.07;
% p.HHZCurrent = 0.03;
% p.HHYCurrent = -0.09;
p.numOfScopPoints = 5000;
% p.chanList = 2;
initinst
initr
%set probe ratio for chan 3 and 4 to 10
% inst.scopes{1}.setProbeRatio(3,10);
% inst.scopes{1}.setProbeRatio(4,10);
%get referance PMT signal
p.s = sqncr;
p.s.addBlock({'Release MOT'})
p.s.addBlock({'pause','duration',1e5});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.coolingPower});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',1e4});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'GenPause','duration',p.MOTLoadTime});
p.s.run();
r.LightBg = max(r.scopeRes{1}(:,3));
p.expName = 'Eddy currents decay, with compretion';


%%
p.DDS1RampUpFreq = 110;
p.MOTReloadTime = 100e3;
p.DDS1RampDownFreq = 89.1060;
p.compressionTime = 50e3;
p.compressionRampTime = 20e3;
% p.MOTReloadTime = 30e3;
p.pauseBetweenRunSteps = 1e-3;
p.compressionEndCurrent = 220;
% p.MOTReleaseTime = 3e3;
nInnerLoop = 1; %MW detuning
nOuterLoop = 1; %Hold Time
resonanceFreq = 34.678261;
startDet = -1000;
startFreq = startDet/1e3+resonanceFreq;
endDet = -5;
endFreq = endDet/1e3 + resonanceFreq;

startHoldTime = 1e3;
endHoldTime = 10e3;
p.settleTime = 1;
startSettleTime = 10e3;
endSettleTime = 10e3;
MWFreqs=linspace(startFreq,endFreq,nInnerLoop);%34.678261 is the theoretical resonance
holdTimeVals = linspace(startHoldTime,endHoldTime,nOuterLoop);
settleTimeVals = linspace(startSettleTime,endSettleTime,nOuterLoop);
p.loopVals={MWFreqs,holdTimeVals};
% p.loopVals={MWFreqs,settleTimeVals};
p.loopVars = {'MWFreq','holdTime'};
% p.loopVars = {'MWFreq','settleTime'};
% p.holdTime = 5e3;
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.(p.loopVars{2})=p.OUTERLOOPVAR;
% p.MOTReleaseTime = 400;
p.MWPulseTime = 120;
p.flashTime = 400;
imagePause = max(p.cameraParams{1}.E2ExposureTime,p.cameraParams{2}.E2ExposureTime);
%start seq
p.s=sqncr();
p.s.addBlock({'SetMWFreq','frequency',p.MWFreq}); %setup MW freq
%Set up cooling AOM DDS scan, for compression
p.s.addBlock({'SetupDDSSweepUpDown','channel',1,'UpFreq',p.DDS1RampUpFreq,'DownFreq',p.DDS1RampDownFreq,'symmetric',0,'UpTime',50,'downTime',p.compressionRampTime});
%ramp up circ coil current
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionRampTime,'EndCurrent',p.compressionEndCurrent});
%start detuning ramp
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.compressionTime,'value','low','inverted','true'});
p.s.addBlock({'pause','duration',p.compressionTime+50}); %pause for compression
%Release MOT and Hold, and measure MW resonance.
p.s.addBlock({'Release MOT'})
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',p.settleTime});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.holdTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.holdTime,'value','high'});
p.s.addBlock({'pause','duration',p.holdTime});
% p.s.addBlock({'TakePic'});
%turn on cooling
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
%pause for flash time
p.s.addBlock({'pause','duration',p.flashTime});
%flash with MW
p.s.addBlock({'setDigitalChannel','channel','MWSourceSwitch','value','high','duration',p.MWPulseTime});
p.s.addBlock({'pause','duration',p.MWPulseTime});
%2nd flash
% p.s.addBlock({'TrigScope'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
p.s.addBlock({'TakePicForMWSpectro'});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
p.looping = int16(1);
% runtmr = tic;
p.s.run();
% toc(runtmr)

%
% imageViewer(r.images{1}(:,:,:))
f = figure;
plotter_EddyCurrentDecay(f,p,r,1);
% zeroLess = [];
% r.truncatedScopeData = [];
% r.normalizationFactor = [];
% r.transferEffitiency = [];
% for ii = 1:length(p.loopVals{1})
%     for jj = 1:length(p.loopVals{2})
%         zeroLess = r.scopeRes{1}(r.scopeRes{1}(:,3,jj,ii)~=0,3,jj,ii);
%         if ~isempty(zeroLess)
%         r.truncatedScopeData(:,jj,ii) = zeroLess;
%         else
%             r.truncatedScopeData(:,jj,ii) = nan;
%         end
%     end
% end
% midPoint = ceil(length(r.truncatedScopeData(:,1,1))/2);
% r.normalizationFactor = squeeze(max(r.truncatedScopeData(1:midPoint,:,:),[],1));
% r.transferEffitiency = (squeeze(max(r.scopeRes{1}(midPoint:end,3,:,:),[],1))-r.LightBg)./(r.normalizationFactor-r.LightBg);
% r.detuning  = (p.loopVals{1} - 34.678261)*1000;
% figure;
% hold on
% if length(p.loopVals{2})>1
%     for ii=1:length(p.loopVals{2})
%         plot(r.detuning,r.transferEffitiency(ii,:)+(ii-1)*0.1,'-o','LineWidth',2)
%         legendList{ii} = sprintf('Hold Time %0.1d [ms]',p.loopVals{2}(ii)*1e-3);
%     end
%     legend(legendList); 
% else
%     plot(r.detuning,r.transferEffitiency,'-o','LineWidth',2)
% end
% xlabel('Deduning from resonance [kHz]')
% ylabel('MW Transfer efficiency')
% set(gca,'FontSize',22)