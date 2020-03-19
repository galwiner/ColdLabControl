clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
p.probeRampTime = 20;
p.probeRampSpan = 75;
p.probeLockCenter = 400;
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2)
p.looping=1;
p.expName = 'Zeeman pumped probe Absorption On Dipole Trap';
%%
% inst.DDS.setFreq(1,63,0,0);
pause(0.3)
p.repumpTime = 1;
p.MOTReleaseTime = 300;
p.DTParams.TrapTime = 2e4;
% p.loopVals{1} = [linspace(0.045,0.055,5),linspace(0.065,0.1,5)];
% p.loopVars{1} = 'DTParams.repumpLoadingPower';
% p.DTParams.repumpLoadingPower = p.INNERLOOPVAR;
p.DTParams.repumpLoadingPower = 0.057;
p.DTParams.coolingLoadingPower = 40;
p.DTParams.coolingLoadingDetuning = -40;
p.DTParams.LoadingTime =  15e4;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.probeRampTime*2,'value','low','description','COOLING OFF'});
% p.s.addBlock({'pause','duration',p.INNERLOOPVAR});
% p.s.addBlock({'pause','duration',6});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'pause','duration',100});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high','description','REPUMP OFF'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',p.probeRampTime*2+50+20,'value','high'});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',p.probeRampTime+50,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.probeRampTime*2+50});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.run();
%%
% data = squeeze(r.scopeRes{1}(:,5,:));
% offset = ones(size(data))*(ones(10,10)+b');
% figure;
% plot(data+offset)
% figure;
% plot(r.scopeRes{1});
time = r.scopeRes{1}(:,1)*1e3-1.047;
time1 = time(time<(p.probeRampTime)*1e-3&time>0);
time2 = time(time>(p.probeRampTime+50)*1e-3&time<(p.probeRampTime*2+50)*1e-3)-(p.probeRampTime+50)*1e-3;
time2 = fliplr(time2);
data =  r.scopeRes{1}(:,5);
data1 = data(time<(p.probeRampTime)*1e-3&time>0);
data2 = data(time>(p.probeRampTime+50)*1e-3&time<(p.probeRampTime*2+50)*1e-3);
df2dt = p.probeRampSpan/(p.probeRampTime*1e-3);
t0 = time1(ceil(end/2));
det = df2dt*(time1-t0);
figure;
% plot(time,data)
plot(det,data1,'o')
hold on;
% hold on
% plot(time2,data2)
%initParams =[OD,Gamma,maxVal,bias,delta0]
initParams = [4,3,0.09,5e-4,-1];
lower = [2,2.5,0.085,5e-4,-2];
upper = [5,4.5,0.095,5e-4,1];
[fitobject,gof,output] = fitExpLorentzian(det,data1,initParams,lower,upper);
extDets = linspace(min(det),max(det),1000);
% [OD,gamma,maxVal,Omega_c,gamma_s,bias,delta0_p,delta0_c]
% initParams = [4,3,0.09,3,0.3,5e-4,-3,-3];
% lower = [2,2.5,0.088,2,0.01,5e-4,-5,-6];
% upper = [5,3.5,0.092,20,6.9,5e-4,-1,0];
% [fitobject,gof,output] = fitEIT(det,data1,initParams,lower,upper);
% hold on;
plot(det,fitobject(det))