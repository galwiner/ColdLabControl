% clear all
global p
% global r
% global inst
% DEBUG=0;
% % init(DEBUG);
% 
% % s=sqncr();
% initp
% p.hasScopResults=0;
% p.hasPicturesResults = 0;
% p.ttDumpMeasurement=1;
% p.hasTTresults = 1;
% p.pfLiveMode=1;
% p.tcLiveMode=1;
% p.postprocessing=0;
% p.calcTemp=0;
% p.DEBUG=DEBUG;
% p.chanList = 2;
% initinst
% initr
% p.looping=1;

%%
currP = p;
if ~isempty(p.loopVals)
    origLoopVals = p.loopVals;
    origLoopVars = p.loopVars;
    p.loopVars = {};
    p.loopVals = {};
else
    origLoopVals = {};
    origLoopVars = {};
end
p.expName = 'Get Noise and Background';
if ~isfield(p,'probeNDLis')
p.probeNDList = [13,3,2];
end
    
if ~isfield(p,'probePower')
p.probePower=1e-10; %in mW
elseif all(p.probePower==p.INNERLOOPVAR)||all(p.probePower==p.OUTERLOOPVAR)
    p.probePower=1e-10; %in mW
end
p.cyclesPerRun=5;
p.gateNum=20000;
p.NAverage = 20;
p.innerLoopDelay = 1;
p.DTParams.MOTLoadTime = 0.1e6;
p.gateTime = 20;
p.MagneticPulseTime=p.gateNum * (p.gateTime+1) + 30e3 ;
p.MOTReloadTime = 1;
p.ZeemanPumpTime = 20;
p.zeemanPumpOn=1;
p.DTParams.TrapTime = 1;
p.s=sqncr();
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrapAndPump'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',100e3}); %this must be at least 10 ms, to let the magnetic field time to settle
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trappcloing time

%measure
p.s.addBlock({'forStart'});
% p.s.addBlock({'pause','duration',1/40}); %first row after for start does not run. this is a "sacraficial" row
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
% p.s.addBlock({'pause','duration',p.gateTime/2});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn on 480 AOM 
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
% p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'measureSPCMWith480Control'});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
%reset
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
cycleTime=p.gateNum*p.gateTime/2;

bgRate=mean(phot_per_cycle)/cycleTime;



p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'LoadDipoleTrapAndPump'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',100e3}); %this must be at least 10 ms, to let the magnetic field time to settle
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'pause','duration',5e3}); %additional trappcloing time
%measure
p.s.addBlock({'forStart'});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
% p.s.addBlock({'pause','duration',p.gateTime/2});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn on 480 AOM 
% p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'measureSPCMNoise'});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
%reset
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();



[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);

noiseRate=mean(phot_per_cycle)/cycleTime;
probePower=p.probePower;
% noiseFileName=fullfile(getCurrentSaveFolder(),['noiseAndBGFile_' num2str(hour(now)),'_' num2str(minute(now)) '.mat']);
noiseFileName=fullfile(getCurrentSaveFolder(),['noiseAndBGFile_' num2str(probePower) '.mat']);

save(noiseFileName,'noiseRate','bgRate','probePower')
p.loopVals = origLoopVals;
p.loopVars = origLoopVars;
% keepDipoleTrapWarm;
p = currP;


