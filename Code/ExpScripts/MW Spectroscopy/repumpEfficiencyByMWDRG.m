%
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


initinst
initr
p.s = sqncr;
p.expName = 'repump characterization by MW DRG';

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
p.MWPulseTime = 100;
MWDDS=inst.MWSource;
% 0.2573
MWDDS.setupSweepMode(34.678261+0.004,0.001,2*p.MWPulseTime,1,1,[],2)

p.expName = 'MWDRG';





p.MOTReleaseTime = 400;

p.flashTime = 600;
p.flashTime = 600;
p.HoldTime = 7e3;
p.flashPower = 690;

%get PMT background
resonanceFreq = 34.678261+0.007; %theoretical resonance + 7 kHz



p.s=sqncr();

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
% p.s.addBlock({'setDigitalChannel','channel','MW_CTL','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','MWSourceSwitch','value','high','duration',p.MWPulseTime});
p.s.addBlock({'pause','duration',p.MWPulseTime});
p.s.addBlock({'setDigitalChannel','channel','MW_CTL','value','high','duration',0});
p.s.addBlock({'pause','duration',2*p.MWPulseTime});
%2nd flash
p.s.addBlock({'TrigScope'});
% p.s.addBlock({'TakePicForMWSpectro'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'setDigitalChannel','channel','MW_CTL','value','low','duration',0});
p.looping = int16(1);
p.s.run();

%%
% f = figure;plotter_findMWResonance(f,p,r,1,0)
r.truncatedScopeData = [];
r.normalizationFactor = [];
r.transferEffitiency = [];
% r.truncatedScopeData =  r.scopeRes{1}(:,2,:,:,:);
midPoint = ceil(size(r.scopeRes{1},1)/2);
r.normalizationFactor = squeeze(max(r.scopeRes{1}(1:midPoint,2,:,1,:,:),[],1));
%find background
% for ii =1:length(p.loopVals{1})
%     for jj = 1:p.NAverage
%     bgInds = find(r.scopeRes{1}(:,3,1,ii,jj)>0.2);
%     minVal(ii,jj) = min(r.scopeRes{1}(bgInds,3,1,ii,jj));
%     end
% end
% bgData = r.scopeRes{1}(midPoint:end,3,1,:,:);
% r.LightBg = 0.2142;
r.transferEffitiency = (squeeze(max(r.scopeRes{1}(midPoint:end,2,1,:,:),[],1))-r.LightBg)./(r.normalizationFactor-r.LightBg);
%remove pronlematic vals
detuning  = (p.loopVals{1} - 34.678261)*1000;
figure;
plot(detuning,r.transferEffitiency)