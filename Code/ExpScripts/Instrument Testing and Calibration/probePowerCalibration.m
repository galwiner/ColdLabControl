clear all
global p
global r
global inst
initp
p.hasTTresults = 1;
p.ttDumpMeasurement=1;
initinst
initr
initinst
initr
p.expName='probe power calibration';
%%
p.probeNDList=[1,2,3];
p.loopVals{1} = logspace(-12,log10(1.9e-10),30);
p.loopVars{1} = 'probePower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.gateTime = 20;
p.gateNum = 5e3;
p.NAverage = 10;
p.cyclesPerRun = 10;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setProbePower','channel','PRBVVAN','value',p.probePower,'duration',0});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','high'}); %probe SPCM shutter
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time 
%measure
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low'}); %probe SPCM shutter
p.s.addBlock({'GenPause','duration',1e4});
p.s.run();
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=ttDumpProcessing(r.fileNames);
[fname,fnum,prefix]=getLastpFile;
[ttfname,ttfnum,ttprefix]=getLastTTfile;
load(ttfname)
load(fname)
fixMissingCycle;
removeDoubleCycle;
setPower = p.loopVals{1};
mean_phot_per_cycle = removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
countRateVec = mean_phot_per_cycle/(p.gateNum*p.gateTime/2);
save('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\probePowerToCountRate','countRateVec','setPower')
