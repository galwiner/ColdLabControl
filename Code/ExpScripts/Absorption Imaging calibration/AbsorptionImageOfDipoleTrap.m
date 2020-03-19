clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Absorption Image Of Dipole Trap';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=2;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=0;
if p.picsPerStep == 1
    p.calcTemp = 0;
else
    p.calcTemp = 1;
end
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{1}.E2ExposureTime=1e3;
% p.cameraParams{1}.ROI = [500,300,550,650];
p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
initinst
initr
%%  
p.imagingPower = 200;
p.AbsImgTime = 10;
% p.MOTLoadTime = 0.5e6;
p.imagingFreq = -1;
p.s=sqncr();
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',40e3});
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'pause','duration',40e3});
p.s.addBlock({'setImagingDetuning','value',p.imagingFreq,'duration',0});
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'pause','duration',2e3});
p.s.addBlock({'Reload MOT'})
p.s.addBlock({'GenPause','duration',100e3})
p.s.run();
%

%
normIm =squeeze((r.images{1}(:,:,2)-200)./(r.images{1}(:,:,1)-200));
% imageViewer(normIm)
% imageViewer(-log(abs(normIm)))
p.GaussianFitThreshold = 0.1;
[fp,gof,fit_img] = fitODGaussian([],[],normIm,'cloudXwidth',10,'cloudYwidth',3,'cloud_center',[107,97]);
disp(fp(6))
