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
p.NAverage = 5;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
p.cameraParams{1}.B1BinningHorizontal = '04';
p.cameraParams{1}.B2BinningVertical = '04';
p.cameraParams{2}.B1BinningHorizontal = '04';
p.cameraParams{2}.B2BinningVertical = '04';
p.cameraParams{2}.E2ExposureTime = 0.1e3;
p.cameraParams{1}.E2ExposureTime = 0.25e3;
% p.cameraParams{2}.E2ExposureTime = 0.005e3;
% p.cameraParams{1}.E2ExposureTime = 0.005e3;
initinst
initr
p.PGCDetuning  = -16*p.consts.Gamma;
AOMcentFreq = 110;
span = abs(p.PGCDetuning-p.coolingDet)/2; %/2 because of double pass
center = AOMcentFreq-span/2;
p.expName = 'Dipole Trap lifetime';
p.PGCFreqRampTime = 100;
p.PGCTime = 40e3;
inst.DDS.setupSweepMode(1,center,span,p.PGCFreqRampTime,1)
p.s.getbgImg();
%% 
% p.loopVars{1} = 'TrapTime';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.numsteps = 4;
% p.NAverage=8;
% p.loopVals{1} = linspace(100e3,400e3,p.numsteps);

p.MOTLoadTime = 3e6;
p.HoldTime = 6e3;
nInner = 20;
trapTimeVals =linspace(40e3,1e6,nInner);
p.TrapTime = p.INNERLOOPVAR;
p.loopVals{1} = trapTimeVals;
p.loopVars{1} = 'TrapTime';
p.PGCEndCoolingPower = 400;
% 
p.s=sqncr();
p.s.addBlock({'Load MOT'});
% p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger photo'});%Trigger camera
% p.s.addBlock({'pause','duration',40e3});
% p.s.addBlock({'Release MOT'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.HoldTime,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.HoldTime,'value','high'});
% p.s.addBlock({'pause','duration',p.HoldTime});
% 
% p.s.addBlock({'pause','duration',1e3})
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.PGCTime,'value','low','inverted','true'});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',p.PGCTime/3,'EndPower',p.PGCEndCoolingPower});
% p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',880,'description','Load MOT: set cooling power'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime,'value','high'});
p.s.addBlock({'pause','duration',p.PGCTime});
p.s.addBlock({'Release MOT'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','low','duration',0,'description','cooling beams off'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','value','low','duration',0,'description','repump beams off'});

p.s.addBlock({'pause','duration',p. });

p.s.addBlock({'TakePic'})

% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','high','duration',0,'description','cooling beams on'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','value','high','duration',0,'description','repump beams on'});
% p.s.addBlock({'endOfSeqToF'})
p.looping = int16(1);
p.s.run();
%
% figure;
% imagesc(r.images{1}-r.bgImg{1})
% figure;
% imagesc(r.images{2}(75:175,50:150))
% if exist(MOTpicPLANE,'var') ~= 0
%     hold on
%     [C,h] = contour(MOTpicPLANE);
%     h.LineColor = 'k';
%     hold off
% end


% figure;
% hold on
% imagesc(r.images{2})
% [C,h] = contour(MOTpicTOP);
% h.LineColor = 'k';
% hold off

%%
% figure;
% imgs = r.images{1}-r.bgImg{1};
% imgsMax = squeeze(max(max(imgs)));
% 
% errorbar(p.loopVals{1},mean(imgsMax,2),std(transpose(imgsMax)))


