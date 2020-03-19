%cooling power sweep with fast mode spectroscopy
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep = 1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=1;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{2}.B1BinningHorizontal = '01';
p.cameraParams{2}.B2BinningVertical = '01';
p.cameraParams{2}.ROI = [350,350,400,300];
p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
initinst
initr
p.expName = 'Top Camera Calibration';
%%
p.flashTime = 150;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;

p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',1.5e3});
p.s.addBlock({'TakePic'});
p.looping = int16(1);
p.s.run();
% imageViewer(r.images{1})
% imageViewer(r.images{2})
%%
[fpPlane,gofPlane,fitImgPlane]=fitImageGaussian2D([],[],r.images{1});
[fpTop,gofTop,fitImgTop]=fitImageGaussian2D([],[],r.images{2});
fpPlane(5)/fpTop(6)



