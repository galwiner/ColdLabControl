
clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=0;
p.hasPicturesResults = 0;
p.ttDumpMeasurement=1;
p.hasTTresults = 1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
p.chanList = 2;
initinst
initr
p.looping=1;
loadNoise
%%

p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.runStep();


p.expName = 'Zeeman Pump Characterization 2 to 2 only';

p.stepTime = 1;
p.freqNum = 35;
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 50;
p.BiasField=-0.05;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [8];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.probePower=1e-10; %in mW
p.cyclesPerRun=50;
p.randomizeLoopVals=0;
p.gateNum=2000;

p.probeCenterOffset=-270;
p.loopVals{1} = (linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum));
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;

p.NAverage = 1;
p.innerLoopDelay = 1;
p.DTParams.MOTLoadTime = 0.5e6;
p.gateTime = 20;
p.MagneticPulseTime=p.gateNum * (p.gateTime+1) + 30e3 ;
p.MOTReloadTime = 1;
p.ZeemanPumpTime = 20;
p.zeemanPumpOn=1;
% fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
% dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
inst.BiasFieldManager.configBpulse([NaN,p.BiasField,NaN],p.MagneticPulseTime);
p.DTParams.TrapTime = 1;
p.repumpTime = 100;
cycleTime = p.gateNum*p.gateTime/2;
f={};
two2twoAbso=zeros(35,20);
for ind=1:20
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %this must be at least 10 ms, to let the magnetic field time to settle
%zeeman pump
if p.zeemanPumpOn
    zeemanChanVal='high';   
else
    
    p.s.addBlock({'setRepumpPower','duration',0,'value',18});
    p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.repumpTime,'value','high'});
    p.s.addBlock({'pause','duration',p.repumpTime});
    zeemanChanVal='low';
    
end
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',p.ZeemanPumpTime,'value',zeemanChanVal});
p.s.addBlock({'pause','duration',p.ZeemanPumpTime});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter. 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trappcloing time
%measure
p.s.addBlock({'forStart'});
p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
%reset
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();
% detVals = p.loopVals{1};
% 
% 
% [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
% two2twoAbsoStep = (phot_per_cycle/cycleTime-p.noiseRate)/(p.bgRate-p.noiseRate);
% NumMissing=length(two2twoAbsoStep)-p.freqNum;
% if NumMissing<0
%     two2twoAbsoStep=[two2twoAbsoStep nan(1,-NumMissing)];
% else
%     two2twoAbsoStep=two2twoAbsoStep(1:p.freqNum);
% end
% 
% two2twoAbso(:,ind) = two2twoAbsoStep;
% 
% [f{end+1},~]=fitExpLorentzian(detVals+266,two2twoAbso(:,ind),[1,3,1,0,-1],[0,3,0.8,0,-20],[100,3,1.1,0,10]);
end
keepDipoleTrapWarm
%%
[fname,fnum,prefix]=getLastpFile;
plist = (fnum-19):fnum;
% freqs = linspace(min(p.loopVals{1
figure;
gca
hold on
for ii = 1:length(plist)
    load([prefix, num2str(plist(ii),'%02d'), '.mat']);
    [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
    two2twoAbsoStep = (phot_per_cycle/cycleTime-p.noiseRate)/(p.bgRate-p.noiseRate);
    dets = p.loopVals{1}+266;
    if length(two2twoAbsoStep)~=length(dets)
        dets = linspace(min(dets),max(dets),length(two2twoAbsoStep));
    end
    plot(dets,two2twoAbsoStep)
end

% figure;
% OD=[];
% for ind=1:8
%     OD(end+1)=f{ind}.OD;
% end
% figure;
% subplot(1,2,1)
% plot(OD)
% xlabel('shot number');
% ylabel('OD');
% set(gca,'fontsize',16)
% subplot(1,2,2)
% plot(detVals+266,-log(two2twoAbso));
% xlabel('Detuning')
% ylabel('Transmission')
% set(gca,'fontsize',16)
% % ylim([-0.01,1]);
% title("spectroscopy F=2 -> F'=2")



