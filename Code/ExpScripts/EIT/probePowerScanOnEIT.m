clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='probe power scan on 70S EIT';
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
p.NAverage = 10;
p.DTParams.TrapTime = 3e4;
p.probeNDList=[1,2];
p.loopVals{1} = linspace(1e-9,10e-9,20);
p.loopVars{1} = 'probePower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s = sqncr;

p.probeDet=-2;
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
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

%measure
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run
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

%%
%measure power
p.s = sqncr;
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
%measure
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run
%analize
time2 = r.scopeRes{1}(:,1,1);
t0Ind2 = 2*find(diff(r.scopeDigRes{1}(:,2,1))==-1,1);
t02 = time2(t0Ind2);%trigger time
t1Ind2 = find(time2>(t02+35e-6),1); %35us after trigger is our starting point
t12 = time2(t1Ind2);
t2Ind2 = find(time2>(t12+p.messTime*1e-6),1); %mees time span
t22 = time2(t2Ind2);
bgDat = squeeze(r.scopeRes{1}(t1Ind2:t2Ind2,5,1,:,:));
meanBgDat = mean(bgDat,3);
bg = squeeze(mean(meanBgDat,1));

figure;
plot(p.loopVals{1},abs./bg)
% plot(p.loopVals{1},abs./p.loopVals{1})

% [OD,Gamma,maxVal,bias,delta0]
% initParams = [30,3,0.5,4.5e-3,-5];
% Lower = [20,2.9,0.45,0,-7];
% Upper = [220,3.1,0.6,5.5e-3,0];
% [fitobject,gof,output,fitFunc] = fitExpLorentzian(p.loopVals{1}',abs',initParams,Lower,Upper);
% hold on
% plot(fitobject)