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
p.numOfScopPoints = 5000;
p.NAverage = 1;
p.chanList = 1;
p.mwSource = 1;
p.HHZCurrent = 0.04;
p.HHYCurrent = -0.065;
p.HHXCurrent = -0.035;

initinst
initr
%get PMT background
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
p.expName = 'MWResonanceSearchV2';


%%
p.MOTReloadTime = 30e3;
p.pauseBetweenRunSteps = 1e-3; %in seconds
p.rabiTime = 112; %measured on 08/05/19
p.flashTime = 600;
p.HoldTime = 10e3;
p.flashPower = 690;

nInnerLoop = 30;
nOuterLoop = 5;
HHzSatart = -0.04;
HHzEnd = -0.03;
resonanceFreq = 34.678261;
startDet = -60;
startFreq = startDet/1e3+resonanceFreq;
endDet = 10;
endFreq = endDet/1e3 + resonanceFreq;
MWFreqs=linspace(startFreq,endFreq,nInnerLoop);%34.678261 is the theoretical resonance
HHZVals = linspace(HHzSatart,HHzEnd,nOuterLoop);
p.loopVals={MWFreqs,HHZVals};
p.loopVars = {'MWFreq','HHXCurrent'};
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.(p.loopVars{2})=p.OUTERLOOPVAR;

p.s=sqncr();
% p.s.addBlock({'Load MOT'});
p.s.addBlock({'SetMWFreq','frequency',p.MWFreq});
p.s.addBlock({'setHH','direction','x','value',p.HHXCurrent});
p.s.addBlock({'Release MOT'})
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.HoldTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.HoldTime,'value','high'});
p.s.addBlock({'pause','duration',p.HoldTime});
%get atom num referance
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.flashPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'pause','duration',100});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime+100,'value','high','description','MW spectro:cooling laser on'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',100,'value','high'});
p.s.addBlock({'pause','duration',100});
%pause for flash time
p.s.addBlock({'pause','duration',p.flashTime});
%flash with MW
p.s.addBlock({'setDigitalChannel','channel','MWSourceSwitch','value','high','duration',p.rabiTime});
p.s.addBlock({'pause','duration',p.rabiTime+1});
%2nd flash
p.s.addBlock({'TrigScope'});
% p.s.addBlock({'TakePicForMWSpectro'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
p.looping = int16(1);
p.s.run();
%
r.truncatedScopeData = [];
r.normalizationFactor = [];
r.transferEffitiency = [];
r.truncatedScopeData =  r.scopeRes{1}(:,2,:,:,:);
midPoint = ceil(length(r.truncatedScopeData(:,1,1,1))/2);
r.normalizationFactor = squeeze(max(r.truncatedScopeData(1:midPoint,:,:,:,:),[],1));

r.LightBg = 0.2142;
r.transferEffitiency = (squeeze(max(r.scopeRes{1}(midPoint:end,2,:,:,:),[],1))-r.LightBg)./(r.normalizationFactor-r.LightBg);
figure;
plot((MWFreqs-resonanceFreq)*1e3,r.transferEffitiency)
legend(string(p.loopVals{2}))