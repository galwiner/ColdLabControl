clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.DEBUG=DEBUG;
p.coolingDet = -4*p.consts.Gamma;
p.PGCDetuning  = -80;
AOMcentFreq = 110;
span = abs(p.PGCDetuning-p.coolingDet)/2; %/2 because of double pass
center = AOMcentFreq-span/2;
p.PGCFreqRampTime = 100;
p.picsPerStep=2;
p.calcTemp=1;
p.NTOF = 2;

p.cameraParams{1}.E2ExposureTime = 50;
initinst
initr
% inst.DDS.setupSweepMode(1,center,span,p.PGCFreqRampTime,1)
p.expName='PGC';
p.SingleTOFTime = 20e3;
% p.TOFtimes = [0,p.SingleTOFTime];
% p.settleTime = 1e3;
% p.PGCTime = 30e3;


p.loopVars = {'PGCTime'};
p.picsPerStep=2;
numSteps=10;
p.NAverage=1;

PGCTimeVals=linspace(5e2,15e3,numSteps);
p.loopVals={PGCTimeVals};
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.SingleTOFTime = 10e3;
p.TOFtimes = [0,p.SingleTOFTime];


%%
p.s.getbgImg();
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger photo'});%Trigger camera
p.s.addBlock({'pause','duration',40e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',p.settleTime})
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.PGCTime,'value','low','inverted','true'});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',p.PGCTime,'EndPower',ceil(p.coolingPower/2)});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime,'value','high'});
p.s.addBlock({'pause','duration',p.PGCTime});
% p.s.addBlock({'pause','duration',p.PGCFreqRampTime+p.SingleTOFTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'GenPause','channel','none','value','none','duration',0.5e6});
p.s.run;
%%

figure;
yyaxis left
errorbar(PGCTimeVals,mean(squeeze(r.fitParams{1}(3,2,1,:,:)),2),std(squeeze(r.fitParams{1}(3,2,1,:,:)),[],2));
hold on
errorbar(PGCTimeVals,mean(squeeze(r.fitParams{1}(4,2,1,:,:)),2),std(squeeze(r.fitParams{1}(4,2,1,:,:)),[],2));
yyaxis right
errorbar(PGCTimeVals,mean(squeeze(r.fitParams{1}(7,2,1,:,:)),2),std(squeeze(r.fitParams{1}(7,2,1,:,:)),[],2));
% errorbar(PGCTimeVals,mean(squeeze(r.fitParams{1}(6,2,1,:,:)),2),std(squeeze(r.fitParams{1}(6,2,1,:,:)),[],2));
% figure;imagesc(r.images{1}(:,:,2,1,1,1))
% figure;imagesc(r.images{1}(:,:,1,1,1,1))