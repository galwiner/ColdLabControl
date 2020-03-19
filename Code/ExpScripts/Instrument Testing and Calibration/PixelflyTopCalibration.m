% 'magnetic trapping for bias compensation'

clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
p.hasPicturesResults=1;
p.pfPlaneLiveMode=0;
p.pfTopLiveMode=0;
p.postprocessing=1;
p.DEBUG=DEBUG;
p.coolingDet = -5.5*p.consts.Gamma;
p.cameraParams{1}.E2ExposureTime = 200;
p.cameraParams{2}.E2ExposureTime = 150;
p.circCurrent=40;
p.calcTemp = 1;
p.TOFtimes = [500,1000,1500,2000];
p.expName='PixelflyTop calibration';
p.picsPerStep=p.NTOF;
p.NAverage=1;
initinst
initr
%%
p.s.getbgImg;
p.s=sqncr();
p.s.addBlock({'ToF'});
p.s.run;
%%
% figure;
% subplot(2,2,1)
% imagesc(r.images{1}-r.bgImg{1})
% subplot(2,2,2)
% imagesc(r.images{2}-r.bgImg{2})
% subplot(2,2,3)
% imagesc(r.fitImages{1})
% subplot(2,2,4)
% imagesc(r.fitImages{2})
% Plane2TopRatio = r.fitParams{1}(5)/inst.cameras('pixelflyPlane').getScale/(r.fitParams{2}(6)/inst.cameras('pixelflyTop').getScale);
% xDim = r.fitParams{2}(5)/cosd(17.5)*Plane2TopRatio
