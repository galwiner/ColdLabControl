clear all
imaqreset
global p
global r
global inst
DEBUG=0;
initp
p.expName='absorption image freq scan';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=2;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=0;
p.absImg{1} = 1;
if p.picsPerStep == 1
    p.calcTemp = 0;
else
    p.calcTemp = 1;
end
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.ROIWidth = 100;
p.ROIHeight = 100;
p.cameraParams{1}.ROI = [p.DTPos{1}(1)-p.ROIWidth/2,p.DTPos{1}(2)-p.ROIHeight/2,p.ROIWidth,p.ROIHeight];
p.cameraParams{1}.E2ExposureTime=1e3;
initinst
initr
%%  
% p.MOTReleaseTime = 1e3;
p.DTParams.MOTLoadTime = 0.75e6;
p.DTParams.TrapTime = 1;
p.AbsImgTime = 25;
p.flashTime = p.AbsImgTime;
p.flashPause = 6;
p.pauseBetweenImages = 200e3;
p.tofTime = 1.3e3;
p.NAverage = 1;
detVAls = linspace(-5,5,20);
p.loopVals{1} = p.coolingLockFreq+detVAls/8;
p.absImgLockFreq = p.INNERLOOPVAR;
p.loopVars{1} = 'absImgLockFreq';
p.s=sqncr();
p.s.addBlock({'setIceEvent','lockFreq',p.absImgLockFreq});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'pause','duration',p.pauseBetweenImages});
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','high'});
p.s.addBlock({'GenPause','duration',5e5})
p.s.run();
%

%
bg = 240;
absIm = squeeze((mean(r.images{1}(:,:,1,1,:,:),6)-bg)./(mean(r.images{1}(:,:,2,1,:,:),6)-bg));
imageViewer(absIm)
