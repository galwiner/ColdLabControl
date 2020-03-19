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
p.postprocessing=0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
p.cameraParams{1}.E2ExposureTime=100;
p.cameraParams{2}.E2ExposureTime=30;
p.cameraParams{1}.ROI = [720,485,200,190];
p.cameraParams{2}.ROI = [310,460,110,200];
initinst
initr
p.expName = 'LoadDipoleTrap test';
%% 
p.trapTime = 40e3;
p.s=sqncr();
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'pause','duration',p.trapTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.run();
imageViewer(r.images{2});
imageViewer(r.images{1});

