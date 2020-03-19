clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep = 1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=0;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{2}.B1BinningHorizontal = '01';
p.cameraParams{2}.B2BinningVertical = '01';
p.cameraParams{2}.ROI = [350,510,50,90];
p.cameraParams{1}.ROI = [760,520,100,100];
p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
initinst
initr
p.expName = 'Dipole Trap focus alignment';
%%
p.flashTime = 150;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
p.PGCPower = 50;
p.PGCTime = 2e3;
p.PGCDetuning = -46;
p.repumpDetuning = 0;
p.TrapTime = 40e3;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',600e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'})
p.s.addBlock({'pause','duration',6e3});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',p.repumpDetuning});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.PGCPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.PGCDetuning});
p.s.addBlock({'pause','duration',p.PGCTime});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'})
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',p.TrapTime});
p.s.addBlock({'TakePic'});
p.looping = int16(1);
p.s.run();




figure;
imagesc(r.images{1})
figure;
imagesc(r.images{2})
hold on;
plot(174,553,'rx')



