%compression and hold cloud size
clear all
global p

global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
p.hasPicturesResults=1;
p.cameraParams{1}.E2ExposureTime = 100;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=1;
p.DEBUG=DEBUG;
p.picsPerStep = 1;
% p.HHXCurrent = -0.07;
% p.HHZCurrent = 0.03;
% p.HHYCurrent = -0.09;
p.numOfScopPoints = 5000;
p.MOTReloadTime = 200e3;
% p.chanList = 2;
initinst
initr
%set probe ratio for chan 3 and 4 to 10
% inst.scopes{1}.setProbeRatio(3,10);
% inst.scopes{1}.setProbeRatio(4,10);

%%
p.s=sqncr();
p.s.addBlock({'Load MOT'})
p.s.addBlock({'Release MOT'})
p.s.addBlock({'pause','duration',200});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',6e3,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',6e3,'value','high'});
p.s.addBlock({'pause','duration',6e3});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'})
p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
p.s.run();
r.baseline={r.fitParams{1}(5),r.fitParams{1}(6),r.atomDensity{1},r.images{1},r.fitImages{1}};



%%
p.expName = 'cloud size after compression';
p.DDS1RampUpFreq = 110;
p.DDS1RampDownFreq = 89.1060; %max density at 0 hold time at 220
% p.DDS1RampDownFreq = 90;
p.compressionTime = 50e3;
p.compressionRampTime = 20e3;
% p.MOTReloadTime = 30e3;
p.pauseBetweenRunSteps = 1e-3;
p.compressionEndCurrent = 220;
% p.MOTReleaseTime = 3e3;
% nInnerLoop = 1; %MW detuning
nOuterLoop = 10; %Hold Time
startHoldTime = 1/40;
endHoldTime = 1e3;
p.settleTime = 200;
% MWFreqs=linspace(startFreq,endFreq,nInnerLoop);%34.678261 is the theoretical resonance
holdTimeVals = linspace(startHoldTime,endHoldTime,nOuterLoop);
compressionEndCurrentVals=ceil(linspace(50,220,nOuterLoop));
% settleTimeVals = linspace(startSettleTime,endSettleTime,nOuterLoop);

% p.loopVals={holdTimeVals};
p.loopVals={compressionEndCurrentVals};
% p.loopVals={MWFreqs,settleTimeVals};
% p.loopVars = {'holdTime'};
p.loopVars = {'compressionEndCurrent'};
% p.loopVars = {'MWFreq','settleTime'};
% p.holdTime = 5e3;
p.(p.loopVars{1})=p.INNERLOOPVAR;
% p.(p.loopVars{2})=p.OUTERLOOPVAR;
% p.MOTReleaseTime = 400;
p.NAverage=1;
p.flashTime = 400;
imagePause = max(p.cameraParams{1}.E2ExposureTime,p.cameraParams{2}.E2ExposureTime);
p.holdTime=0.1e3;

%start seq (assumes we start with a loaded MOT)
p.s=sqncr();
% p.s.addBlock({'SetMWFreq','frequency',p.MWFreq}); %setup MW freq
%Set up cooling AOM DDS scan, for compression
p.s.addBlock({'SetupDDSSweepUpDown','channel',1,'UpFreq',p.DDS1RampUpFreq,'DownFreq',p.DDS1RampDownFreq,'symmetric',0,'UpTime',50,'downTime',p.compressionRampTime});
%ramp up circ coil current
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionRampTime,'EndCurrent',p.compressionEndCurrent});
%start detuning ramp
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.compressionTime,'value','low','inverted','true'});
p.s.addBlock({'pause','duration',p.compressionTime}); %pause for compression
%Release MOT and Hold
p.s.addBlock({'Release MOT'})
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',p.settleTime});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.holdTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.holdTime,'value','high'});
p.s.addBlock({'pause','duration',p.holdTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
p.looping = int16(1);
p.s.run();
averageVals=squeeze(mean(r.fitParams{1},5));
stdVals=squeeze(std(r.fitParams{1},0,5));
% CloudXSizes = r.fitParams{1}(5,:);
% CloudYSizes = r.fitParams{1}(6,:);
CloudXSizes = averageVals(5,:);
stdX=stdVals(5,:);
CloudYSizes = averageVals(6,:);
stdY=stdVals(6,:);
figure;
subplot(2,1,1)
errorbar(p.loopVals{1},CloudXSizes,stdX,'-or')
% plot(p.loopVals{1},CloudXSizes,'-or') 
hold on
errorbar(p.loopVals{1},CloudYSizes,stdY,'-ok')

line([0 p.loopVals{1}(end)],[r.baseline{1} r.baseline{1}],'LineStyle','--','Color','r')
line([0 p.loopVals{1}(end)],[r.baseline{2} r.baseline{2}],'LineStyle','--','Color','k')
title('cloud size decay')


% figure;
subplot(2,1,2)
atomDensity=mean(squeeze(r.atomDensity{1}),2);
var_atomDensity=std(squeeze(r.atomDensity{1}),0,2);
errorbar(p.loopVals{1},atomDensity,var_atomDensity,'ob');
hold on
line([0 p.loopVals{1}(end)],[r.baseline{3} r.baseline{3}],'LineStyle','--','Color','b')
title('atom density decay')