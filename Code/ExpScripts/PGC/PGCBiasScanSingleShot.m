clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
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
p.PGCFreqRampTime = 500;
p.picsPerStep=1;
p.cameraParams{1}.E2ExposureTime = 150;
p.expName='PGC bias scan single shot';
p.SingleTOFTime = 20e3;
p.settleTime = 1e3;
p.PGCTime=10e3;
p.loopVars={'HHZCurrent'};
numSteps=15;
p.NAverage=1;
HHZCurrentVals=linspace(0,0.1,numSteps);
p.PGCEndCoolingPower = 150;
initinst
initr
p.s.getbgImg();
p.loopVals={HHZCurrentVals};
p.(p.loopVars{1})=p.INNERLOOPVAR;
inst.DDS.setupSweepMode(1,center,span,p.PGCFreqRampTime,1)
%Ploting params
p.plotingParams.xaxis = p.loopVals{1};

p.plotingParams.yaxes = {r.fitParams{1}(5,1,1,:,1),r.fitParams{1}(6,1,1,:,1)};
%%
p.s=sqncr();
p.s.addBlock({'setHH','direction','z','value',p.HHZCurrent})
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',p.settleTime})
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.PGCTime,'value','low','inverted','true','description','PGC: DDS CTRL'});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',p.PGCFreqRampTime,'EndPower',p.PGCEndCoolingPower});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime,'value','high','description','PGC: Cooling ON'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime,'value','high','description','PGC: Repump ON'});
p.s.addBlock({'pause','duration',p.PGCTime+p.SingleTOFTime,'description','PGC: pause during PGC'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'GenPause','channel','none','value',0,'duration',0.3e6});
p.s.run;
%%
figure;
plot(p.loopVals{1},squeeze(r.fitParams{1}(5,:)),'-o')
hold on
plot(p.loopVals{1},squeeze(r.fitParams{1}(6,:)),'-o')