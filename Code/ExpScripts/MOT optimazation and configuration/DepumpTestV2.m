clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.picsPerStep = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp = 0;
p.DTPic = 0;
p.DEBUG=DEBUG;
initinst
initr
p.expName = 'DepumpTest';
%%
p.probeDet = -3;
p.repumpTime = 30;
% p.depumpTime = 10;
p.loopVals{1} = linspace(10,100,10);
p.loopVars{1} = 'depumpTime';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.probeNDList = 3;
p.probePower = 2e-6;
p.holdTime = 300;
p.s = sqncr;
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
%jump to depump freq
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','value','high','duration',1});
p.s.addBlock({'pause','duration',1e3});
%repump
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.repumpTime});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.holdTime});
%messure
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',20});
p.s.addBlock({'pause','duration',20});
%turn on trap and hold
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.holdTime});
%depump
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','value','high','duration',p.depumpTime});
p.s.addBlock({'pause','duration',p.depumpTime});
%turn on trap and hold
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.holdTime});
%messure
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',20});
p.s.addBlock({'pause','duration',20});
%jump to cooling freq
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','value','high','duration',1});
p.s.run();
%
figure;
plot(squeeze(r.scopeRes{1}(:,5,:)))
