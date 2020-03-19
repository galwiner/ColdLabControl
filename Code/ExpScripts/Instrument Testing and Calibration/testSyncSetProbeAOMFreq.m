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
p.hasSpecResults=1;
p.hasPicturesResults = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
p.benchtopSpecRes = 1;
initinst
initr

p.looping=1;
p.expName = 'testSyncSetProbeAOMFreq';
%%
p.spectrumAnaParams{1}.centerFreq = 200;
p.spectrumAnaParams{1}.span = 100; 
p.stepTime = 1;
p.freqNum = 10;
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 75;
p.probeLockCenter = 400;
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2,0,1e-1*p.freqNum,p.freqNum)

p.loopVals{1} = ((1:p.freqNum)-1)*p.stepTime;
p.loopVars{1} = 'freqJumpPause';
p.(p.loopVars{1}) = p.INNERLOOPVAR;

p.s=sqncr();
p.s.addBlock({'syncSetProbeAOMFreq','freqJumpPause',p.freqJumpPause});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();
