clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='slowModeSpectroscopy';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
p.hasScopResults=1;
p.hasPicturesResults=0;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr

%%
% inst.DDS.setFreq(1,341.6,0,0);
p.chanList = [2];
p.messTime = 70;
p.repumpTime = 100;
p.NAverage = 1;
p.DTParams.TrapTime = 3e4;
p.scanCenter = -3.5;
p.scanSpan = 60;
p.loopVals{1} = linspace(p.scanCenter-p.scanSpan/2,p.scanCenter+p.scanSpan/2,30);
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s = sqncr;
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','value','high','duration',0});

p.s.addBlock({'LoadDipoleTrap'});
%repump
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
p.s.addBlock({'pause','duration',p.repumpTime});
%messure
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',3e3});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','value','low','duration',0});
p.s.addBlock({'GenPause','duration',0.6e5});
p.s.run
%
time = r.scopeRes{1}(:,1,1);
t0Ind = 2*find(diff(r.scopeDigRes{1}(:,2,1))==-1,1);
t0 = time(t0Ind);%trigger time
t1Ind = find(time>(t0+35*1e-6),1); %200us after trigger is our starting point
t1 = time(t1Ind);
t2Ind = find(time>(t1+p.messTime*1e-6),1); %mees time span
t2 = time(t2Ind);
absDat = squeeze(r.scopeRes{1}(t1Ind:t2Ind,3,1,:,:));
meanAbsDat = mean(absDat,3);
abs = squeeze(mean(meanAbsDat,1));
bgt1 = find(time>(t0+1e-3),1); %background data starts after 1 ms
bgt2 = find(time>(t0+2e-3),1); %background data stops after 2 ms
bgData = squeeze(r.scopeRes{1}(bgt1:bgt2,3,1,:,:));
meanBgData = mean(bgData,3);
bg = (mean(meanBgData,1));
abso = abs./bg;

figure;
plot(p.loopVals{1},abso)
% [OD,Gamma,maxVal,bias,delta0]
initParams = [15,3,0.93,0.1,-5];
Lower = [10,2.9,0.91,0.1,-7];
Upper = [25,3.1,0.96,0.11,-4];
[fitobject,gof,output,fitFunc] = fitExpLorentzian(p.loopVals{1}',abs',initParams,Lower,Upper);
hold on
plot(fitobject)
