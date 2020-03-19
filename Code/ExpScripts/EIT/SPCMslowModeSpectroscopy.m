clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='SPCM slowModeSpectroscopy sanity with cooling repump (not zeeman)';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
p.hasScopResults=0;
p.hasPicturesResults=0;
p.hasTTresults=1;
p.ttDumpMeasurement=1;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;

p.DEBUG=DEBUG;
initinst
initr
%%
p.pauseBetweenRunSteps = 1;
p.repumpTime = 100;
p.NAverage = 1;
p.cyclesPerRun=40;
p.randomizeLoopVals=0;
p.gateNum=2000;
p.probeNDList=[1,2,3];
p.probePower=5e-11;
p.loopVals{1} = linspace(-30,15,30);
p.loopVals{1}=fliplr(p.loopVals{1});
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;

p.DTParams.MOTLoadTime = 1;
p.MOTReloadTime = 1e5;
p.s = sqncr;
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
% p.s.addBlock({'setHH','direction','x','value',0.1});
% p.s.addBlock({'startTTgatedCount','countVectorLen',p.TTbinsPerStep});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0}); %Blue light shutter off
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0}); %Blue light AOM on
p.s.addBlock({'pause','duration',5e3}); %shutter close delay
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','high','duration',0}); %open the shutter but switch off the blue light
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',5e3}); %shutter open delay
%repump
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
p.s.addBlock({'pause','duration',p.repumpTime});

%measure
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',10});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0}); %Blue AOM on but shutter off.(keeping AOM hot)
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','value','low','duration',0});
p.s.addBlock({'pause','duration',5e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',5e5}); 
p.s.run

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
load(matFileName)


figure;
plot(p.loopVals{1},phot_per_cycle./max(phot_per_cycle),'o')
% plot(p.loopVals{1},phot_per_cycle,'o')
% plot(phot_per_cycle,'o')
% figure;
% plot(p.loopVals{1},squeeze(sum(r.cnt(1,:,:),2)+sum(r.cnt(2,:,:),2)))
% ylabel('counts')
% xlabel('detuning [MHz]')
% set(gca,'fontsize',16)
% title('EIT at 1pW')
% %%
% figure;
% plot(r.cnt(1,:,15))
