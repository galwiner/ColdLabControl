clear all;
instrreset;
global p;
global r;
global inst;
initp;
p.expName = 'test scope high res';
p.hasScopResults=1;
p.chanList=[1];
p.runSettlingLoop = 0;
initinst;
initr;
inst.BiasFieldManager.I = p.Blue_Killer_I;
scp = inst.scopes{1};
scp.setTimebase(3)
scp.setDelay(1.5);
p.MOTLoadTime = 3e6;
p.trigPulseTime = 1e4;
% ChannelToggler(p.chanNames.UVLED,1)
scp.setAcquisitionType('HRES');

%%
p.s = sqncr;
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({'Load MOT'});
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({p.atomicActions.GenPause,'duration',1e5});
p.s.run;

%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
figure;
plot(r.scopeRes{1}(:,1),r.scopeRes{1}(:,2),'o','MarkerSize',0.5);
