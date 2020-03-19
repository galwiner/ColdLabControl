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
p.hasPicturesResults = 0;
p.ttDumpMeasurement=1;
p.hasTTresults = 1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
p.chanList = 1;
initinst
initr
p.looping=1;

%%
p.expName = 'Dipole Trap PMT sigal';

p.stepTime = 1;
% p.freqNum = 20;
% p.probeRampTime = p.stepTime*p.freqNum;
% p.probeRampSpan = 40;
% p.probeCenterOffset=-4;
% p.probeLockCenter = probeDetToFreq(0,1)+p.probeCenterOffset;
p.BiasField=0.5;
% p.DTParams.repumpLoadingPower = 0.035;
p.probeNDList = [1,3,2];
p.ZeemanNDList = [8,6];
p.zeemanRepumpND=[10]; %list with values of the ND filters used in the zeeman repump for this measurement
p.probePower=5e-11; %in mW
p.cyclesPerRun=40;
p.randomizeLoopVals=0;
p.gateNum=2000;

% inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)
% pause(2)
% p.loopVals{1} = ((1:p.freqNum)-1)*p.stepTime;
% p.loopVars{1} = 'freqJumpPause';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.loopVals{1} = fliplr(linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum));
% p.loopVars{1} = 'probeDet';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.NAverage = 50;
p.innerLoopDelay = 1;
p.DTParams.MOTLoadTime = 0.1e6;
p.gateTime = 20;
p.ZeemanPumpTime=p.gateNum * (p.gateTime+1) + 30e3 ;
p.MOTReloadTime = 1;
% fname=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
% dump=TTDump(inst.tt,fname,1e9,[1,2,3]);
inst.BiasFieldManager.configBpulse([NaN,p.BiasField,NaN],p.ZeemanPumpTime);
% p.DTParams.TrapTime=0.1e6;
p.DTParams.TrapTime = 1;
p.repumpTime = 100;
p.probeDet=7;

% testLock()
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',10e3}); %this must be at least 10 ms, to let the magnetic field time to settle
%zeeman pump
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',3,'value','high'});
p.s.addBlock({'pause','duration',3});
p.s.addBlock({'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low'}); %zeeman shutter. 
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 


p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trappcloing time
% 
% %measure
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
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
%reset
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3});


%flash for PMT reading
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',690});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','High';})
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','High',});
p.s.addBlock({'pause','duration',1e3});

p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
mean_phot_per_cycle = meanPhot_per_cycle(phot_per_cycle,p.NAverage);
% figure;
% plot(p.loopVals{1}(1:length(mean_phot_per_cycle)),mean_phot_per_cycle./max(mean_phot_per_cycle),'-o')
% figure
% plot(phot_per_cycle./max(phot_per_cycle),'-o')

PMTSig = squeeze(mean(r.scopeRes{1}(:,2,:)));
PMTSig(PMTSig==0) = nan;
figure;
plot(PMTSig/max(PMTSig));
hold on
plot(phot_per_cycle./max(phot_per_cycle),'-o')



% r.scopeRes{1}