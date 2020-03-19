
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


p.expName = 'Zeeman Pump Characterization magnetic field sweep';

p.stepTime = 1;
p.freqNum = 25;
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 50;
p.probeCenterOffset=-4;
% p.BiasField=-0.0;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [8];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.probePower=10e-11; %in mW
p.cyclesPerRun=50;
p.randomizeLoopVals=0;
p.gateNum=2000;
p.loopVals{1} = (linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum));
p.loopVars{1} = 'probeDet';
p.biasFieldNum=10;
p.loopVals{2} = linspace(-0.25,0.0,p.biasFieldNum);
p.loopVars{2} = 'BiasField';



p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.(p.loopVars{2}) = p.OUTERLOOPVAR;
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
% biasFieldVals=linspace(-0.2,0.2,10);
%     inst.BiasFieldManager.configBpulse([NaN,p.BiasField,NaN],p.MagneticPulseTime);


p.DTParams.TrapTime = 1;
p.repumpTime = 100;
cycleTime = p.gateNum*p.gateTime/2;
% currDetVal = inst.DDS.getFreq(2)*8
% resetProbeLock([p.loopVals{1}(1),currDetVal])


p.s=sqncr();

p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setBiasPulse','BiasField',p.BiasField,'MagneticPulseTime',p.MagneticPulseTime})
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
p.s.addBlock({'GenPause','duration',5e4});
p.s.run();

p.probeCenterOffset=-270;
currDetVal = p.loopVals{1}(end);
p.loopVals{1} = (linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum));
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;

resetProbeLock([p.loopVals{1}(1),currDetVal])

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
two2threeAbso = (phot_per_cycle/cycleTime-p.noiseRate)/(p.bgRate-p.noiseRate);
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setBiasPulse','BiasField',p.BiasField,'MagneticPulseTime',p.MagneticPulseTime})
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
detVals = p.loopVals{1};
keepDipoleTrapWarm

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
two2twoAbso = (phot_per_cycle/cycleTime-p.noiseRate)/(p.bgRate-p.noiseRate);
%%


NumMissing=length(two2twoAbso)-p.freqNum*length(p.loopVals{2});
if NumMissing<0
    two2twoAbso=[two2twoAbso nan(1,-NumMissing)];
else
    two2twoAbso=two2twoAbso(1:p.freqNum*length(p.loopVals{2}));
end
two2twoAbso=reshape(two2twoAbso,p.freqNum,length(p.loopVals{2}));

NumMissing=length(two2threeAbso)-p.freqNum*length(p.loopVals{2});
if NumMissing<0
    two2threeAbso=[two2threeAbso,nan(1,-NumMissing)];
else
    two2threeAbso=two2threeAbso(1:p.freqNum*length(p.loopVals{2}));
end
two2threeAbso=reshape(two2threeAbso,p.freqNum,length(p.loopVals{2}));


figure;
for ind=1:p.biasFieldNum
[f1,gof1]=fitExpLorentzian(detVals+266,two2twoAbso(:,ind),[1,3,1,0,-1],[0,3,1,0,-20],[100,3,1.1,0,10]);
[f2,gof2]=fitExpLorentzian(detVals+266,two2threeAbso(:,ind),[1,3,1,0,-1],[0,3,1,0,-20],[100,3,1.1,0,10]);

subplot(5,5,ind) 
plot(detVals+266,two2twoAbso(:,ind))
hold on
plot(detVals+266,two2threeAbso(:,ind))
plot(f1)
plot(f2)
title(sprintf('Zeeman Pumping. OD = %0.1f. OD Ratio ->2/->3: %.2f',f2.OD,f1.OD/f2.OD),'fontsize',12)
end


% 
% figure;
% if length(detVals)>length(two2threeAbso)
%    plot(linspace(min(detVals)+266,max(detVals+266),length(two2threeAbso)),two2threeAbso,'linewidth',2); 
% else
% plot(detVals+266,two2threeAbso,'linewidth',2);
% end
% 
% hold on
% if length(detVals)>length(two2twoAbso)
%     plot(linspace(min(detVals)+266,max(detVals+266),length(two2twoAbso)),two2twoAbso,'linewidth',2); 
% else
%     plot(detVals+266,two2twoAbso,'linewidth',2)
% end
% legend('F=2->F''=3','F=2->F''=2')
% xlabel('Detuning')
% ylabel('Transmission')
% set(gca,'fontsize',16)
% ylim([-0.01,1]);
% [f1,gof1]=fitExpLorentzian(detVals+266,two2twoAbso,[1,3,1,0,-1],[0,3,1,0,-20],[100,3,1.1,0,10]);
% [f2,gof2]=fitExpLorentzian(detVals+266,two2threeAbso,[1,3,1,0,-1],[0,3,1,0,-20],[100,3,1.1,0,10]);
% plot(f2,'r-')
% 
% plot(f1,'g-')
% title(sprintf('Zeeman Pumping. OD = %0.1f. OD Ratio ->2/->3: %.2f',f2.OD,f1.OD/f2.OD),'fontsize',12)



