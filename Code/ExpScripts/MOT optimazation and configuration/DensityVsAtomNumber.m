clear all
global p
global r
global inst
initp
p.expName='Density vs atom number';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=2;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{1}.E2ExposureTime=50;
p.cameraParams{1}.ROI = [300,400,700,400];
initinst
initr


%%  
p.MOTLoadTime = 3e6;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
p.NAverage = 10;
p.compressionEndCurrent=220;
p.compressionRampTime = 40e3; %in us
p.compressionDetuning = -45;
% p.loopVals{1} = linspace(8e6,8e6,1);
% p.loopVars{1} = 'MOTLoadTime';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.loopVars = {'coolingPower'};
coolingPowerVals=linspace(300,1000,15);
p.loopVals={coolingPowerVals};
p.(p.loopVars{1})=p.INNERLOOPVAR;
% p.compressionTime = 10e3;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',1e6});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.compressionDetuning});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionRampTime,'EndCurrent',p.compressionEndCurrent});
p.s.addBlock({'pause','duration',p.compressionRampTime+100});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'TakePic'});
p.s.run();
%%
meanPreCompAtomNum = squeeze(mean(r.atomNum{1}(1,1,:,:),4));
mwanPostCompDensity = squeeze(mean(r.atomDensity{1}(2,1,:,:),4));
meanPostCompAtomNum = squeeze(mean(r.atomNum{1}(2,1,:,:),4));
meanPostCompAtomVolume = meanPostCompAtomNum./mwanPostCompDensity;
figure;
yyaxis left
plot(p.loopVals{1},meanPreCompAtomNum);
yyaxis right
plot(p.loopVals{1},mwanPostCompDensity)
figure;
yyaxis left
plot(meanPreCompAtomNum,mwanPostCompDensity)
yyaxis right
plot(meanPreCompAtomNum,meanPostCompAtomVolume)

