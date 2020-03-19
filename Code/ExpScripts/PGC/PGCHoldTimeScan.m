%cooling power sweep with fast mode spectroscopy
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
p.hasPicturesResults=1;
p.picsPerStep = 1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=1;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
p.cameraParams{1}.B1BinningHorizontal = '04';
p.cameraParams{1}.B2BinningVertical = '04';
p.cameraParams{2}.B1BinningHorizontal = '04';
p.cameraParams{2}.B2BinningVertical = '04';
p.cameraParams{2}.E2ExposureTime = 100;
p.cameraParams{1}.E2ExposureTime = 100;
% p.cameraParams{2}.E2ExposureTime = 0.005e3;
% p.cameraParams{1}.E2ExposureTime = 0.005e3;
initinst
initr
% p.PGCDetuning  = -16*p.consts.Gamma;
% AOMcentFreq = 110;
% span = abs(p.PGCDetuning-p.coolingDet)/2; %/2 because of double pass
% center = AOMcentFreq-span/2;
p.expName = 'PGC Hold Time scan';
% p.PGCFreqRampTime = 100;
% p.PGCTime = 10e3;
% inst.DDS.setupSweepMode(1,center,span,p.PGCFreqRampTime,1)
p.s.getbgImg();
% scp = keysightScope('10.10.10.118',[],'ip');
%% 
% p.loopVars{1} = 'TrapTime';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.numsteps = 4;
% p.NAverage=8;
% p.loopVals{1} = linspace(100e3,400e3,p.numsteps);
p.TOFtimes =[10,15,20,25]*1e3;
p.MOTLoadTime = 8e6;
% p.HoldTime = 6e3;
p.TrapTime = 40e3;
% p.MOTReleaseTime = 500;
% p.PGCEndCoolingPower = 400;
p.PGCDetuning = -80;
p.PGCPower = 100;
p.PGCTime = 3e3;
p.loopVals{1} = linspace(10,300,5); %Hold Time
% p.loopVals{2} = linspace(50,600,10); %Hold Time
p.loopVars = {'HoldTime'};
p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.(p.loopVars{2}) = p.OUTERLOOPVAR;

% 
% scp.setState('single')
roi = [44,202,48,136];
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'TrigScope'})
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.HoldTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.HoldTime,'value','high'});
p.s.addBlock({'pause','duration',p.HoldTime});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime,'value','high'});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.PGCDetuning});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.PGCPower,'description','Load MOT: set cooling power'});
p.s.addBlock({'pause','duration',p.PGCTime});
p.s.addBlock({'Release MOT'});
% p.s.addBlock({'Pause','duration',25e3});
p.s.addBlock({'TakePic'});
% p.s.addBlock({'endOfSeqToF'})
p.looping = int16(1);
p.s.run();
imageViewer(r.images{1})