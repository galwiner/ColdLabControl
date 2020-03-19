clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Post Compression thermometry';
p.coolingDet = -3*p.consts.Gamma;
p.hasScopResults=1;
p.hasPicturesResults=1;
p.picsPerStep=p.NTOF;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.calcTemp = 1;
p.cameraParams{1}.E2ExposureTime=100;
p.compressionTime = 50e3;
p.DEBUG=DEBUG;
%Scan setup
p.PGCDetuning  = p.INNERLOOPVAR;
Nsteps = 10;
p.NAverage=1;
spanVals = (-3-linspace(-10,-5,Nsteps))*p.consts.Gamma/2;
UpFreq = 110;
DownFreqVals = UpFreq-spanVals;
DownFreq = p.INNERLOOPVAR;
p.loopVals ={DownFreqVals};
p.loopVars = {'DownFreq'};
%
initinst
initr
p.compressionRampTime = 20e3; %in us
p.compressionEndCurrent=220;

%%

p.s=sqncr();
p.s.addBlock({'SetupDDSSweepUpDown','channel',1,'UpFreq',UpFreq,'DownFreq',DownFreq,'symmetric',0,'UpTime',50,'downTime',p.compressionRampTime});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionRampTime,'EndCurrent',p.compressionEndCurrent});
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.compressionTime,'value','low','inverted','true'});
p.s.addBlock({'pause','duration',50e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'endOfSeqToF'});
p.looping = int16(1);
p.s.run();

%%
