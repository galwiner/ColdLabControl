clear all
global p
global r
global inst
initp
p.hasTTresults = 0;
p.ttDumpMeasurement=0;
p.hasScopResults=1;
initinst
initr

inst.scopes{1} = keysightScope('10.10.10.19',[],'ip');
p.probeNDList = [13,3,2];
%%
p.gateNum = 100;
p.expName = 'test probe pulse';
p.blueAOMVVAN = 5.6;
p.probePower=3e-9;
p.NAverage = 1;
p.cyclesPerRun = 10;
p.gateTime = 20;
p.ControlDelay = 1; %measured on 06/10/19
p.ttGateDelay = 50e-3; %measured on 06/10/19
p.ControlTurnoffDelay = 0.500; %measured on 06/10/19
p.ProbeTurnoffDelay = 0.500; %measured on 06/10/19

p.s=sqncr();
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
%measure

p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'forStart'});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});...
% p.s.addBlock({'pause','duration',p.probeDelay}); 76
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel',p.chanNames.pixelflyPlaneTrig,'value','high','duration',0});...
%     p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
% % p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});...
% 
% p.s.addBlock({'pause','duration',p.gateTime/2});...
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});...
% p.s.addBlock({'pause','duration',p.probeDelay}); 
% p.s.addBlock({'setDigitalChannel','channel',p.chanNames.pixelflyPlaneTrig,'value','low','duration',0});...
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
% 


% % p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});...
% p.s.addBlock({'pause','duration',p.gateTime/2});...
% p.s.addBlock({'measureSPCMWith480Control'});
% p.s.addBlock({'pulse480only'});
% p.s.addBlock({'measureSPCMOnlyProbe'});
p.s.addBlock({'measureSPCMNoise'});


p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 

p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn off 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});...
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();
%
clear data
smt = 50;
t = smooth(r.scopeRes{1}(:,1),smt)*1e6-8;
for ii = 1:4
    data(:,ii) = smooth(r.scopeRes{1}(:,ii+1),smt);
end
t0 = 0.42;
figure;
plot(t-t0,data(:,1:2)./max(data(:,1:2)));
grid minor
xlabel('time [\mus]')
ylabel('normelized signals')
legend('480 light','DT (blue beam)','Probe','TTGate');
title('Rydberg EIT pulse synchronization')
set(gca,'fontsize',16)
xlim([0 200])
% savefig('D:\Box Sync\Lab\ExpCold\Measurements\2020\01\01\Rydberg EIT pulse synchronization')


