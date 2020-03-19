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
p.I0 = p.B0./p.HHGaussPerAmp;
p.HHXCurrent = p.I0(1);
p.HHYCurrent = p.I0(2);
p.HHZCurrent = p.I0(3);
initinst
initr
%get PMT background

p.s = sqncr;
% p.s.addBlock({'SetMWFreq','frequency',resonanceFreq});
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
p.expName = 'Find MW rabi';


%%
p.MOTReloadTime = 30e3;
p.pauseBetweenRunSteps = 1e-3; %in seconds
nInnerLoop = 20;
nOuterLoop = 2;
startRabiTime = 10;
endRabiTime = 200;
resonanceFreq = 34.678261;
startDet = 4;
startFreq = startDet/1e3+resonanceFreq;
endDet = 6;
endFreq = endDet/1e3 + resonanceFreq;
rabiTimeVals=linspace(startRabiTime,endRabiTime,nInnerLoop);
p.loopVals={rabiTimeVals};
p.loopVars = {'rabiTime'};
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.loopVals{2}=linspace(startFreq,endFreq,nOuterLoop);
dets = (p.loopVals{2}-resonanceFreq)*1e3; %dets in kHz
p.loopVars{2} = 'MWFreq';
p.(p.loopVars{2})=p.OUTERLOOPVAR;
p.flashTime = 600;
p.HoldTime = 7e3;
p.flashPower = 690;

p.s=sqncr();
% p.s.addBlock({'Load MOT'});
p.s.addBlock({'SetMWFreq','frequency',p.MWFreq});
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
p.s.addBlock({'setDigitalChannel','channel','MWSourceSwitch','value','high','duration',p.rabiTime});
p.s.addBlock({'pause','duration',endRabiTime+1});
%2nd flash
p.s.addBlock({'TrigScope'});
% p.s.addBlock({'TakePicForMWSpectro'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
p.looping = int16(1);
p.s.run();

r.truncatedScopeData = [];
r.normalizationFactor = [];
r.transferEffitiency = [];
midPoint = ceil(size(r.scopeRes{1},1)/2);
r.normalizationFactor = squeeze(max(r.scopeRes{1}(1:midPoint,2,:,:),[],1));
r.transferEffitiency = (squeeze(max(r.scopeRes{1}(midPoint:end,2,:,:),[],1))-r.LightBg)./(r.normalizationFactor-r.LightBg);
r.transferEffitiency(r.transferEffitiency==1) = nan;
figure;
gca
hold on
for ii = 1:length(p.loopVals{2})
   plot(p.loopVals{1},r.transferEffitiency(ii,:),'o-');
end
