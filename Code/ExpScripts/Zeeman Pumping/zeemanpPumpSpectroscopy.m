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
p.expName = 'zeemanpPumpSpectroscopy';
%%
p.DTParams.MOTLoadTime = 5e5;
p.flashTime = 1e3-300;
p.chanList = 4;
p.repumpTime = 20;
% p.zeemanDet = linspace(-5,5,1);
% p.loopVals{1} = -286+p.zeemanDet;
p.loopVals{1} = linspace(-25,25,25)-20;
p.loopVars{1} = 'coolingDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.DTParams.TrapTime = 20e3;
p.s=sqncr();
p.s.addBlock({'setICEDetuning','Laser Name','cooling','detuning',p.coolingDet,'evtNum',2});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','duration',0,'value','high'});
p.s.addBlock({'LoadDipoleTrap'});
%jump cooling freq
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});

% repump
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.repumpTime});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',1e3});
%measure


p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',1});
p.s.addBlock({'TrigScope'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',p.ZeemanPumpTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',10,'value','high'});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',10,'value','high'});
p.s.addBlock({'pause','duration',20});
%%depump
% p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
% p.s.addBlock({'setCoolingPower','duration',0,'value',690});
% p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
% p.s.addBlock({'pause','duration',300});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high'});
% p.s.addBlock({'pause','duration',p.flashTime});
% p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
% p.s.addBlock({'pause','duration',300});
% p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',100,'value','high'});
% p.s.addBlock({'pause','duration',100});
%reset
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();
%
bgVa = 0.555;
bgVa = 0.555*0.4964;
bgVa = 0.555*0.151;
bgVa = 0.555*0.151*0.4964;
bgVa = 0.555*0.151*0.4964*0.5441;
bgVa = 0.555*0.151*0.4964/0.0368*0.0088;
data = squeeze(mean(r.scopeRes{1},1));
data = data(5,:);
figure;
plot(p.loopVals{1}+20,data/bgVa)