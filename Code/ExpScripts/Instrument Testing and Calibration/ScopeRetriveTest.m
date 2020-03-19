clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=1;
p.hasPicturesResults = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr

p.looping=1;
p.expName = 'scope retrive test';
%%
inst.scopes{1}.setTimebase(0.1);
p.trigPulseTime = 3000;
p.chanList = [1,2,3,4];
% p.chanList = 4;
p.pauseBetweenRunSteps = 0.1;
p.loopVals{1} = 1:10;
p.loopVars{1}= 'delayTime';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'pause','duration',p.delayTime});
p.s.addBlock({'TrigScope'});
p.s.run();
