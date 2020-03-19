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
p.chanList = [1,4];
p.numOfScopPoints = 5000;
% p.HHXCurrent = -0.0366;
% p.HHYCurrent = -0.0677;
% p.HHZCurrent = 0.04;

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
% inst.BiasFieldManager.B=[0,0.5,0];
p.s = sqncr;
p.s.addBlock({'Release MOT'})
p.s.addBlock({'pause','duration',1e5});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.coolingPower});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',1e4});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'GenPause','duration',p.MOTLoadTime});
p.s.run();
r.LightBg = max(r.scopeRes{1}(:,2));


%%
% p.BiasScanDirection = 'y';
nInnerLoop =100;
nOuterLoop = 1;
% 0.036
% HHSatart = -0.0744;
% HHEnd =-0.0744;
resonanceFreq = 34.678261;
startDet = 3200;
startFreq = startDet/1e3+resonanceFreq;
endDet = 3300;
endFreq = endDet/1e3 + resonanceFreq;

p.expName = 'Find MW rabi';




MWFreqs=linspace(startFreq,endFreq,nInnerLoop);%34.678261 is the theoretical resonance
if nOuterLoop==1
MWtime=linspace(100,100,nOuterLoop);
else
    MWtime=linspace(10,8,nOuterLoop);
end
% HHZVals = linspace(HHSatart,HHEnd,nOuterLoop);
p.loopVals={MWFreqs,MWtime};
p.loopVars = {'MWFreq','MWPulseTime'};
% p.loopVars = {'MWFreq','HHZCurrent'};
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.(p.loopVars{2})=p.OUTERLOOPVAR;
p.MOTReleaseTime = 400;
% p.MWPulseTime = 60;
p.flashTime = 600;
% imagePause = max(p.cameraParams{1}.E2ExposureTime,p.cameraParams{2}.E2ExposureTime);
p.flashTime = 600;
p.HoldTime = 5e3;
p.flashPower = 690;

%get PMT background
% resonanceFreq = 34.678261+0.007; %theoretical resonance + 7 kHz
% Binit=inst.BiasFieldManager.B;
Binit = [-0.297360000000000,-0.324012000000000,0.483880000000000];

inst.BiasFieldManager.B=[Binit(1),0.5,Binit(3)];

p.s=sqncr();
p.s.addBlock({'SetMWFreq','frequency',p.MWFreq});
% p.s.addBlock({'setHH','direction',p.BiasScanDirection,'value',p.(p.loopVars{2})});
% p.s.addBlock({'setHH','direction',p.BiasScanDirection,'value',p.HHZCurrent});
% p.s.addBlock({'Release MOT'})
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low','description','Release MOT:COOLING OFF'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','Release MOT:REPUMP OFF'})
p.s.addBlock({'setAnalogChannel','channel','CircCoil','duration',0,'value',0,'description','Release MOT:CURRENT OFF'});
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

%
% f = figure;plotter_findMWResonance(f,p,r,1,0)
r.truncatedScopeData = [];
r.normalizationFactor = [];
r.transferEffitiency = [];
% r.truncatedScopeData =  r.scopeRes{1}(:,2,:,:,:);
midPoint = ceil(size(r.scopeRes{1},1)/2);
r.normalizationFactor = squeeze(max(r.scopeRes{1}(1:midPoint,2,:,:,:,:),[],1));
%find background
% for ii =1:length(p.loopVals{1})
%     for jj = 1:p.NAverage
%     bgInds = find(r.scopeRes{1}(:,3,1,ii,jj)>0.2);
%     minVal(ii,jj) = min(r.scopeRes{1}(bgInds,3,1,ii,jj));
%     end
% end
% bgData = r.scopeRes{1}(midPoint:end,3,1,:,:);
% r.LightBg = 0.2142;
r.transferEffitiency = (squeeze(max(r.scopeRes{1}(midPoint:end,2,:,:,:),[],1))-r.LightBg)./(r.normalizationFactor-r.LightBg);
r.transferEffitiency(r.transferEffitiency==1) = nan;
%remove pronlematic vals
detuning  = (p.loopVals{1} - resonanceFreq)*1000;
figure;
if nOuterLoop~=1
plot(p.loopVals{2},r.transferEffitiency)
else
    plot(detuning,r.transferEffitiency)
end
% imagesc(r.transferEffitiency)