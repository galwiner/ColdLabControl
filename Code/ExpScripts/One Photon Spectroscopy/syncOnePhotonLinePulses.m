clear all
global p
global r
global inst
initp
p.hasScopResults=1;
initinst
initr
SetProbePower(1e-11,[1,2,3])
%%
p.expName = 'sync one photon line Pulses';
p.gateTime = 20;
p.ttGateDelay = 50e-3;
p.probeTurnOffDelay = -0.175;
p.s=sqncr();
p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0}); %1 
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0}); %1
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0}); %1
p.s.addBlock({'pause','duration',p.ttGateDelay});   %2
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0}); %1
p.s.addBlock({'pause','duration',p.gateTime/2-p.ttGateDelay+p.probeTurnOffDelay}); %345
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});%1
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});%1
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});%1
p.s.addBlock({'pause','duration',p.gateTime/2- 0.200});%380
p.s.addBlock({'forEnd','value',2});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});%1
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});%1
p.s.run;
t = (r.scopeRes{1}(:,1)-r.scopeRes{1}(5148,1))*1e6;
figure;
plot(t,r.scopeRes{1}(:,[2,4,5])./max(r.scopeRes{1}(:,[2,4,5])))
xlabel('time [\mus]')
title('one phoron line pulses sync')
ylabel('normelized signal')
legend('DT Blue','DT Purple','Probe')
set(gca,'fontsize',14)
grid minor
