clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='SPCM EIT vs probe power';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
p.hasScopResults=0;
p.hasPicturesResults=0;
p.hasTTresults=1;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr

%%
% inst.DDS.setFreq(1,341.6,0,0);
p.messTime = 100;
p.repumpTime = 20;
p.NAverage = 1;
p.TTbinsPerStep=100;
p.probeNDList=[1,3,2];
% p.probePower=1e-10;
p.probeDet = -2.5;
p.NAverage = 1;
p.DTParams.TrapTime = 3e4;
p.loopVals{1} = linspace(5e-12,1.9e-10,20);
p.loopVars{1} = 'probePower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s = sqncr;
p.s.addBlock({'startTTgatedCount','countVectorLen',p.TTbinsPerStep});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0}); %Blue light shutter off
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0}); %Blue light AOM on
p.s.addBlock({'pause','duration',5e3}); %shutter close delay
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','high','duration',0}); %open the shutter but switch off the blue light
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',5e3}); %shutter open delay
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
p.s.addBlock({'forStart'});

p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'TrigScope'});

p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',10});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',100});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',100});
p.s.addBlock({'pause','duration',100});
p.s.addBlock({'forEnd','value',p.TTbinsPerStep});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0}); %Blue AOM on but shutter off.(keeping AOM hot)
p.s.addBlock({'GenPause','duration',1e6}); 
p.s.run

data = r.cnt;
%get Bg
p.s = sqncr;
p.s.addBlock({'startTTgatedCount','countVectorLen',p.TTbinsPerStep});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
p.s.addBlock({'pause','duration',5e3}); %shutter open delay
%measure
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',10});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',100});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',100});
p.s.addBlock({'pause','duration',100});
p.s.addBlock({'forEnd','value',p.TTbinsPerStep});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','low','duration',0});
p.s.addBlock({'pause','duration',5e3}); %shutter close delay
p.s.addBlock({'GenPause','duration',0.1e6}); 
p.s.run
bg = r.cnt;
%%
dataSum  = squeeze(sum(data(1,:,:,:),2)+sum(data(3,:,:,:),2));
meanData = mean(dataSum,2);
bgSum  = squeeze(sum(bg(1,:,:,:),2)+sum(bg(3,:,:,:),2));
meanBg = mean(bgSum,2);
%calculating the transmission. we measured 34 muW before the cell. ~32 muW
%after the lenses and 11.7*2=23.4 in both paths of the fibers.
trens = 23.4/34;
QE = 0.7;
incomingRate = meanBg/QE/trens;

figure;
plot(incomingRate/1000,meanData./meanBg)
xlabel('Measured incoming photon rate [photon/\mus]');
ylabel('Normelized Transmittion');
set(gca,'fontsize',16)
