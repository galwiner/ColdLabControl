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
initinst
initr
p.expName = 'cooling power sweep';
p.loopVars = {'coolingPower','circCurrent'};
coolingPowerVals=linspace(300,1000,10);
circCurrentVals = linspace(300,1000,10);
p.loopVals={coolingPowerVals,};
p.(p.loopVars{1})=p.INNERLOOPVAR;

p.MOTLoadTime = 8e6;

p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'TakePic'});
p.looping = int16(1);
p.s.run();
%%
figure;
plot(p.loopVals{1},squeeze(r.atomNum{1}))

