clear all
global p
global r
global inst
DEBUG=0;
initp

p.hasScopResults=1;
p.hasPicturesResults = 0;
p.hasTTresults = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr

p.looping=1;
p.expName = 'IceFreqJumpRate';
%%
p.DTParams.MOTLoadTime = 5e5;
p.flashTime = 3e3;
p.chanList = 4;
p.repumpTime = 10;
p.zeemanDet = linspace(-10,10,1);
% p.loopVals{1} = -286+p.zeemanDet;
p.loopVals{1} = -296;
p.loopVars{1} = 'coolingLaserDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.DTParams.TrapTime = 25e3;
p.s=sqncr();
p.s.addBlock({'setICEDetuning','Laser Name','cooling','detuning',p.coolingLaserDet,'evtNum',2});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',3.5e3});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();
%
data = squeeze(mean(r.scopeRes{1},1));
data = data(5,:);
figure;
plot(p.zeemanDet,data)