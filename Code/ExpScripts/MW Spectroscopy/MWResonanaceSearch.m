%fast mode spectroscopy on a cold cloud, in live camera mode
clear all
global p

global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.picsPerStep = 1;
p.HHXCurrent = -0.045;
p.HHZCurrent = 0.044;
p.HHYCurrent = -0.077;
p.numOfScopPoints = 5000;
% p.chanList = 2;
initinst
initr
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
p.expName = 'Find MW resonance';


%%
p.MOTReloadTime = 30e3;
p.pauseBetweenRunSteps = 1e-3;
p.BiasScanDirection = 'z';
biasLoopVar = ['HH',upper(p.BiasScanDirection),'Current'];
nInnerLoop = 70;
nOuterLoop = 10;
BiasCurrSatart = 0.06;
BiasCurrEnd = 0.03;
resonanceFreq = 34.678261;
startDet = -170;
startFreq = startDet/1e3+resonanceFreq;
endDet = -10;
endFreq = endDet/1e3 + resonanceFreq;

MWFreqs=linspace(startFreq,endFreq,nInnerLoop);%34.678261 is the theoretical resonance
BiasVals = linspace(BiasCurrSatart,BiasCurrEnd,nOuterLoop);

p.loopVals={MWFreqs,BiasVals};
p.loopVars = {'MWFreq',biasLoopVar};
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.(p.loopVars{2})=p.OUTERLOOPVAR;
p.MOTReleaseTime = 400;
p.MWPulseTime = 120;
p.flashTime = 300;
imagePause = max(p.cameraParams{1}.E2ExposureTime,p.cameraParams{2}.E2ExposureTime);
p.HoldTime = 6e3;
p.s=sqncr();
p.s.addBlock({'SetMWFreq','frequency',p.MWFreq});
p.s.addBlock({'setHH','direction',p.BiasScanDirection,'value',p.(biasLoopVar)});
% p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'})
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.HoldTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.HoldTime,'value','high'});
p.s.addBlock({'pause','duration',p.HoldTime});
%turn on cooling
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
%pause for flash time
p.s.addBlock({'pause','duration',p.flashTime});
%flash with MW
p.s.addBlock({'setDigitalChannel','channel','MWSourceSwitch','value','high','duration',p.MWPulseTime});
p.s.addBlock({'pause','duration',p.MWPulseTime});
%2nd flash
p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePicForMWSpectro'});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
p.looping = int16(1);
% runtmr = tic;
p.s.run();
% toc(runtmr)

%
zeroLess = [];
r.truncatedScopeData = [];
r.normalizationFactor = [];
r.transferEffitiency = [];
for ii = 1:length(p.loopVals{1})
    for jj = 1:length(p.loopVals{2})
        zeroLess = r.scopeRes{1}(r.scopeRes{1}(:,3,jj,ii)~=0,3,jj,ii);
        if ~isempty(zeroLess)
        r.truncatedScopeData(:,jj,ii) = zeroLess;
        else
            r.truncatedScopeData(:,jj,ii) = nan;
        end
    end
end
midPoint = ceil(length(r.truncatedScopeData(:,1,1))/2);
r.normalizationFactor = squeeze(max(r.truncatedScopeData(1:midPoint,:,:),[],1));
r.transferEffitiency = (squeeze(max(r.scopeRes{1}(midPoint:end,3,:,:),[],1))-r.LightBg)./(r.normalizationFactor-r.LightBg);
% r.transferEffitiency = (squeeze(max(r.scopeRes{1}(midPoint:end,3,:,:),[],1)))./(r.normalizationFactor);
% r.transferEffitiency = squeeze(max(r.scopeRes{1}(midPoint:end,3,:,:),[],1));
r.detuning  = (p.loopVals{1} - 34.678261)*1000;
figure;
hold on
if length(p.loopVals{2})>1
    for ii=1:length(p.loopVals{2})
        plot(r.detuning,r.transferEffitiency(ii,:)+(ii-1)*0.2,'-o','LineWidth',2)
        legendList{ii} = sprintf('HH%s current %0.2f [mA]',upper(p.BiasScanDirection),p.loopVals{2}(ii)*1e3);
    end
    legend(legendList); 
else
    plot(r.detuning,r.transferEffitiency,'-o','LineWidth',2)
end
xlabel('Deduning from resonance [kHz]')
ylabel('MW Transfer efficiency')
set(gca,'FontSize',22)