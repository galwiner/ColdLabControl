%cooling power sweep with fast mode spectroscopy
clear all
clear global
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0 ;
p.hasPicturesResults=1;
p.picsPerStep = 4;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=1;
p.calcTemp = 1;
p.DEBUG=DEBUG;
p.cameraParams{2}.E2ExposureTime = 0.10e3;
p.cameraParams{1}.E2ExposureTime = 0.1e3;
p.NAverage = 1;
initinst
initr
p.PGCDetuning  = -16*p.consts.Gamma;
AOMcentFreq = 110;
span = abs(p.PGCDetuning-p.coolingDet)/2; %/2 because of double pass
center = AOMcentFreq-span/2;
p.expName = 'Magnetic Compression';
p.PGCFreqRampTime = 100;

inst.DDS.setupSweepMode(1,center,span,p.PGCFreqRampTime,1)
p.s.getbgImg();
%% 
% global r;
p.PGCTime = 40e3;
p.TOFtimes = [1,5e3,10e3,20e3];
p.MOTLoadTime = 3e6;
p.HoldTime = 6e3;
p.TrapTime = 200e3;
p.PGCEndCoolingPower = 400;
p.compressionRampTime = 33e3;
p.compressionHoldTime = 1;
p.compressionEndCurrent = 220;
% p.delayForPic = 1e3;
inerrLoopN = 1;
startDelayForPic = 1e4;
endDelayForPic = 5e4;
delayForPicVals = linspace(startDelayForPic,endDelayForPic,inerrLoopN);
% p.loopVars{1} = 'delayForPic';
% p.delayForPic = p.INNERLOOPVAR;
% p.loopVals{1} = delayForPicVals;
% inst.BiasCoils(
% for ind=1:30
p.currTurnOnTime =1;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
% p.s.addBlock({'Release MOT'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.HoldTime,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.HoldTime,'value','high'});
% p.s.addBlock({'pause','duration',p.HoldTime});
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.PGCTime+p.currTurnOnTime,'value','low','inverted','true'});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',p.PGCTime/3,'EndPower',p.PGCEndCoolingPower});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime,'value','high'});
p.s.addBlock({'pause','duration',p.PGCTime+10});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',0,'value','high'});
% p.s.addBlock({'setCircCurrent','channel','CircCoil','duration',0,'value',40});
% p.s.addBlock({'TrigScope'});
% p.s.addBlock({'pause','duration',p.currTurnOnTime});
% p.s.addBlock({'TakePic'})
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','low','duration',0,'description','cooling beams off'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','value','low','duration',0,'description','repump beams off'});
% p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',0,'value','high'});
% p.s.addBlock({'setCircCurrent','channel','CircCoil','duration',0,'value',10});
% p.s.addBlock({'TrigScope'});
% p.s.addBlock({'pause','duration',1});
% p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionRampTime,'EndCurrent',p.compressionEndCurrent});% p.s.addBlock({'pause','duration',p.compressionRampTime});
% p.s.addBlock({'pause','duration',p.delayForPic}); %pause for a set time, than take pic
% %compleate the compretion, and release
% p.s.addBlock({'pause','duration',10}); %extra hold, otherwise further commands to the analog channel fail (this is a bug)
% p.s.addBlock({'pause','duration',p.compressionRampTime});

p.s.addBlock({'Release MOT'});

p.s.addBlock({'endOfSeqToF'})
p.looping = int16(1);
p.s.run();

%
 imageViewer(r.images{1}-r.bgImg{1})
% figure(1)
% imagesc(r.images{1}(:,:,:)-r.bgImg{1})
% % imagesc(r.images{2}(:,:,:))
% colorbar
% caxis([0 1000])
% title(string(datetime))
% end
% imageViewer(r.images{1}(:,:,:)-r.bgImg{1},r.x{1},r.y{1});
% imageViewer(r.images{2}(:,:,:)-r.bgImg{2},r.x{2},r.y{2});
% imageViewer(r.images{2}(:,:,:))
% imageViewer(r.fitImages{1}(:,:,:),r.x{1},r.y{1});



