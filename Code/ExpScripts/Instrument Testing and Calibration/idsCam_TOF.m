clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=1;
p.DEBUG=DEBUG;
% p.coolingDet = -3*p.consts.Gamma;
p.picsPerStep=p.NTOF;
p.calcTemp=0;
p.NTOF = 10;
p.TOFtimes = linspace(1,4,p.NTOF)*1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
initinst
initr
p.MOTReloadTime = 1e6;
p.expName='ids cam Thermometry';
%%

cam=idsCam;
cam.setHWTrig;
cam.startRingBufferMode(p.NTOF);
cam.setExposure(1e3);

%%
% p.s.getbgImg();
p.s=sqncr();
% % p.s.addBlock({'Load MOT'})
% p.s.addBlock({'Release MOT'})
% p.s.addBlock({'pause','duration',3000})
% p.s.addBlock({'TakePic'});
% % p.s.addBlock({'pause','duration',10e6})
% p.s.addBlock({'Reload MOT'})
p.s.addBlock({'ToF'});
p.s.runStep;
%
% imageViewer(r.images{1})
images=cam.getBufferImages;
imageViewer(images)