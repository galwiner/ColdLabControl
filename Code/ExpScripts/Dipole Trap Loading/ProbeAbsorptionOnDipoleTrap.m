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
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
% fclose(inst.DDS.s)
% SHU2_initial_2016(1,0,1)
% DRG_LAB_2(100,80,4e-6,4e-6,10000,10000)
p.probeRampTime = 20;
p.probeRampSpan = 75;
% p.probeLockCenter = probeDetToFreq(0,1);
p.probeLockCenter = 400;
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2)
p.looping=1;
p.expName = 'Probe Absorption On Dipole Trap';
%%
% inst.DDS.setFreq(1,63,0,0);
p.MOTReleaseTime = 300;
p.DTParams.TrapTime = 2e4;
p.DTParams.repumpLoadingPower = 0.057;
p.DTParams.coolingLoadingPower = 40;
p.DTParams.coolingLoadingDetuning = -40;
p.DTParams.LoadingTime =  15e4;
p.tofTime =1e3;
p.DepumpTime = 400;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
% p.s.addBlock({'Load MOT'});
% p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.probeRampTime*2,'value','low','description','COOLING OFF'});
% p.s.addBlock({'pause','duration',p.INNERLOOPVAR});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high','description','REPUMP OFF'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high','description','REPUMP OFF'});
p.s.addBlock({'pause','duration',20});
%start scan
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.probeRampTime});
%start depump
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.DepumpTime});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',20});
%scan back
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});

% p.s.addBlock({'pause','duration',4.1e3});
p.s.run();
%
[freq,startInds,endInds]=getDDSTriangleRampFreqVec(r.scopeRes{1}(:,1),r.scopeDigRes{1}(:,9),p.probeRampSpan,0);
absor = r.scopeRes{1}(startInds(1):endInds(1),5)./fliplr(r.scopeRes{1}(startInds(2):endInds(2),5)')';
figure;
plot(freq,absor)


%initParams =[OD,Gamma,maxVal,bias,delta0]
% initParams = [4,3,0.09,5e-4,-1];
% lower = [2,2.5,0.085,5e-4,-2];
% upper = [5,4.5,0.095,5e-4,1];
% [fitobject,gof,output] = fitExpLorentzian(det,data1,initParams,lower,upper);
% extDets = linspace(min(det),max(det),1000);
% % [OD,gamma,maxVal,Omega_c,gamma_s,bias,delta0_p,delta0_c]
% % initParams = [4,3,0.09,3,0.3,5e-4,-3,-3];
% % lower = [2,2.5,0.088,2,0.01,5e-4,-5,-6];
% % upper = [5,3.5,0.092,20,6.9,5e-4,-1,0];
% % [fitobject,gof,output] = fitEIT(det,data1,initParams,lower,upper);
% % hold on;
% plot(det,fitobject(det))