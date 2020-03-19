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
p.hasTTresults = 1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
p.looping=1;
p.expName = 'cooling repump freq scan';
%%

nFreqs=15;
p.loopVals{1} = linspace(-20,20,nFreqs); %in MHz
p.loopVars{1} = 'repumpFreq';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.NAverage = 1;
p.innerLoopDelay = 1;
p.DTParams.MOTLoadTime = 1000e3;
p.chanList=1;
% inst.Lasers('cooling').setEventData(coolingDetToFreq(-290,8),2,3,0); %10 MHz above resonance
p.DTParams.TrapTime=1;
p.s=sqncr();
p.s.addBlock({'setICEFreq','Laser Name','repump','freq',p.repumpFreq});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();

pmtReadMean=squeeze([mean(r.scopeRes{1}(:,2,1,:))]);
figure;
plot(p.loopVals{1},pmtReadMean)
