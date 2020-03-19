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
p.coolingDet = -6*p.consts.Gamma;
initinst
initr
p.s = sqncr;
p.s.addBlock({'Load MOT'});
p.s.run;

p.expName='FindOptimalFeedForward';
p.loopVars = {'FeedForward'};
p.NAverage=1;
p.LoopSteps = 10;
FeedForward=linspace(0.15,0.3,p.LoopSteps);
p.loopVals={FeedForward};
p.(p.loopVars{1})=p.INNERLOOPVAR;
% p.FeedForward = 0.25;
% sc=keysightScope('10.10.10.118','MOTSCOPE','ip');
%%
% sc.setState('single')
p.s=sqncr();
p.s.addBlock({'setICEDetuning','Laser Name','cooling','detuning',0,'evtNum',2,'FeedForward',p.FeedForward});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',300,'value','low','inverted','true'});...
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',300,'value','low','inverted','true'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',10,'value','High'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',1e3});

p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',10,'value','High'});
% p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','channel','none','value','none','duration',0.5e6});
p.s.run;



