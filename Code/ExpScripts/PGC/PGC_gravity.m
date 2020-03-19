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
p.coolingDet = -3*p.consts.Gamma;
p.PGCDetuning  = -10*p.consts.Gamma;
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
inst.DDS.setupSweepMode(1,center,span,p.PGCFreqRampTime,1)
p.expName='PGC + gravity measurement';

p.loopVars = {'SingleTOFTime'};
p.picsPerStep=2;
numSteps=10;
p.NAverage=1;

p.settleTime = 100;
p.PGCTime = 30e3;
SingleTOFTimeVals=linspace(5e3,15e3,numSteps);
p.loopVals={SingleTOFTimeVals};
p.(p.loopVars{1})=p.INNERLOOPVAR;
% p.SingleTOFTime = 20e3;
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
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.PGCTime+p.PGCFreqRampTime,'value','low','inverted','true'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime+p.PGCFreqRampTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime+p.PGCFreqRampTime,'value','high'});
p.s.addBlock({'pause','duration',p.PGCTime+2*p.PGCFreqRampTime});
p.s.addBlock({'pause','duration',p.SingleTOFTime});
p.s.addBlock({'TakePic'});
p.s.run;
%%
imageViewer(squeeze(r.fitImages{1}(:,:,2,1,:)))

yvals=-squeeze(r.fitParams{1}(4,2,1,:));
[f,gof]=fit(SingleTOFTimeVals',yvals,'poly2');
figure;plot(SingleTOFTimeVals,-squeeze(r.fitParams{1}(4,2,1,:)),'-o')
hold on
plot(SingleTOFTimeVals,f(SingleTOFTimeVals),'r-');