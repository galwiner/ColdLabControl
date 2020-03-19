clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='ControlAlignmentOnProbe';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
p.hasScopResults=1;
p.hasPicturesResults=0;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=1;
p.DEBUG=DEBUG;
initinst
initr

%%
% inst.DDS.setFreq(1,341.6,0,0);
p.messTime = 100;
p.repumpTime = 20;
p.NAverage = 1;
p.DTParams.TrapTime = 3e4;
p.probeDet = -2;
figure;
for ii = 1:50
p.s = sqncr;
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
%repump
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.repumpTime});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',1e3});
%messure
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run

%
time = r.scopeRes{1}(:,1,1);
t0Ind = 2*find(diff(r.scopeDigRes{1}(:,2,1))==-1,1);
t0 = time(t0Ind);%trigger time
t1Ind = find(time>(t0+35e-6),1); %35us after trigger is our starting point
t1 = time(t1Ind);
t2Ind = find(time>(t1+p.messTime*1e-6),1); %mees time span
t2 = time(t2Ind);
absDat = squeeze(r.scopeRes{1}(t1Ind:t2Ind,5,1,:,:));
meanAbsDat = mean(absDat,3);
abs = squeeze(mean(meanAbsDat,1));
% figure;
plot(abs)
end