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
p.mwSource = 1;
p.chanList = 1;
p.numOfScopPoints = 5000;
% p.HHXCurrent = -0.0366;
% p.HHYCurrent = -0.0677;
% p.HHZCurrent = 0.04;
p.I0 = p.B0./p.HHGaussPerAmp;
p.HHXCurrent = p.I0(1);
p.HHYCurrent = p.I0(2);
p.HHZCurrent = p.I0(3);
initinst
initr
p.s = sqncr;
%get bg scope
% p.s.addBlock({'Release MOT'})
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high','description','MW spectro:cooling laser on'});
% p.s.addBlock({'pause','duration',10e3});
% p.s.addBlock({'TrigScope'});
% p.s.run;
% r.bgscope = r.scopeRes{1};
p.expName = 'Find MW resonance';
% scp = keysightScope('10.10.10.118','MOTSCOPE','ip');

p.s = sqncr;
p.s.addBlock({'Release MOT'})
p.s.addBlock({'pause','duration',1e5});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.coolingPower});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',1e4});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'GenPause','duration',p.MOTLoadTime});
p.s.run();
r.LightBg = max(r.scopeRes{1}(:,2));


%%
p.BiasScanDirection = 'y';
nInnerLoop = 40;
nOuterLoop = 1;
% 0.036
HHSatart = -0.074;
HHEnd =-0.074;
resonanceFreq = 34.678261+0.005;
startDet = -100;
startFreq = startDet/1e3+resonanceFreq;
endDet = 100;
endFreq = endDet/1e3 + resonanceFreq;

p.expName = 'Find MW rabi';
p.NAverage = 1;



MWFreqs=linspace(startFreq,endFreq,nInnerLoop);%34.678261 is the theoretical resonance
HHVals = linspace(HHSatart,HHEnd,nOuterLoop);
p.loopVals={MWFreqs,HHVals};
% p.loopVals={MWFreqs};
p.loopVars = {'MWFreq',['HH' ,upper(p.BiasScanDirection), 'Current']};
% p.loopVars = {'MWFreq'};
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.(p.loopVars{2})=p.OUTERLOOPVAR;
p.MOTReleaseTime = 400;
p.MWPulseTime = 120;
p.flashTime = 600;
imagePause = max(p.cameraParams{1}.E2ExposureTime,p.cameraParams{2}.E2ExposureTime);
p.flashTime = 600;
p.HoldTime = 7e3;
p.flashPower = 690;

%get PMT background

% inst.BiasFieldManager.B=[0,0.5,0];

p.s=sqncr();
p.s.addBlock({'SetMWFreq','frequency',p.MWFreq});
p.s.addBlock({'setHH','direction',p.BiasScanDirection,'value',p.(p.loopVars{2})});
% p.s.addBlock({'setHH','direction',p.BiasScanDirection,'value',p.HHZCurrent});
p.s.addBlock({'Release MOT'})
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.HoldTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.HoldTime,'value','high'});
p.s.addBlock({'pause','duration',p.HoldTime});
%get atom num referance
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.flashPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
% p.s.addBlock({'pause','duration',100});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime+100,'value','high','description','MW spectro:cooling laser on'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',100,'value','high'});
p.s.addBlock({'pause','duration',100});
%pause for flash time
p.s.addBlock({'pause','duration',p.flashTime});
%flash with MW
p.s.addBlock({'setDigitalChannel','channel','MWSourceSwitch','value','high','duration',p.MWPulseTime});
p.s.addBlock({'pause','duration',p.MWPulseTime});
%2nd flash
p.s.addBlock({'TrigScope'});
% p.s.addBlock({'TakePicForMWSpectro'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'Reload MOT'});
p.looping = int16(1);
p.s.run();

f = figure;plotter_findMWResonance(f,p,r,1,0)
% f = figure;plotter_BiasCancelation(f,p,r,1,0);
% r.truncatedScopeData = [];
% r.normalizationFactor = [];
% r.transferEffitiency = [];
% % r.truncatedScopeData =  r.scopeRes{1}(:,2,:,:,:);
% midPoint = ceil(length(r.truncatedScopeData(:,1,1,1))/2);
% r.normalizationFactor = squeeze(max(r.truncatedScopeData(1:midPoint,:,1,:,:),[],1));
% %find background
% % for ii =1:length(p.loopVals{1})
% %     for jj = 1:p.NAverage
% %     bgInds = find(r.scopeRes{1}(:,3,1,ii,jj)>0.2);
% %     minVal(ii,jj) = min(r.scopeRes{1}(bgInds,3,1,ii,jj));
% %     end
% % end
% % bgData = r.scopeRes{1}(midPoint:end,3,1,:,:);
% % r.LightBg = 0.2142;
% r.transferEffitiency = (squeeze(max(r.scopeRes{1}(midPoint:end,2,1,:,:),[],1))-r.LightBg)./(r.normalizationFactor-r.LightBg);
% %remove pronlematic vals
% detuning  = (p.loopVals{1} - 34.678261)*1000;
% figure;
% plot(detuning,r.transferEffitiency)
