clear all;
instrreset;
global p;
global r;
global inst;
initp;
p.expName = 'my first MOT';
p.hasScopResults=1;
p.chanList=[1];
initinst;
initr;
%%
p.loopVars{1}='MOTLoadTime';
p.MOTLoadTime=p.INNERLOOPVAR;
p.loopVals{1}=linspace(1,1e6,10);
p.s = sqncr;
p.s.addBlock({'Load MOT'});
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({p.atomicActions.GenPause,'duration',1e5});
p.s.run;

%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
figure;
plot(p.loopVals{1},squeeze(mean(r.scopeRes{1}(:,2,:))));