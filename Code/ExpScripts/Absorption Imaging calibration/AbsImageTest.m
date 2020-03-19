clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='absorption image test';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=2;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.absImg{1} = 1;
if p.picsPerStep == 1
    p.calcTemp = 0;
else
    p.calcTemp = 1;
end
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{1}.E2ExposureTime=1e3;
% p.cameraParams{1}.ROI = [700,400,300,300];
% p.imagingPower = 50;
initinst
initr
%%  
% p.MOTReleaseTime = 1e3;
p.imagingPower = 200;
p.AbsImgTime = 10;
p.flashTime = p.AbsImgTime;
% nsteps = 5;
% imageingPowerVals = linspace(10,60,nsteps);
p.flashPause = 6;
p.MOTLoadTime = 2e6;
% p.loopVals{1} =linspace(-8,8,15);
% p.loopVars{1} = 'imagingFreq';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.pauseBetweenImages = 200e3;
p.s=sqncr();
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',40e3});
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setCircCurrent','channel','CircCoil','duration',0,'value',220});
p.s.addBlock({'pause','duration',40e3});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',-60});
p.s.addBlock({'pause','duration',8e3});
p.s.addBlock({'Release MOT'});
% p.s.addBlock({'pause','duration',1e3});
% p.s.addBlock({'setImagingDetuning','value',p.imagingFreq,'duration',0});
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'GenPause','duration',100e3})
% p.s.addBlock({'setImagingPower','channel','ImagingVVAN','duration',0,'value',p.imagingPower,'description','set imaging power'});
% p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High','description','picture:trigger photo'});%Trigger camera
% p.s.addBlock({'pause','duration',p.flashPause});%pixelfly intrinsic delay
% p.s.addBlock({'setDigitalChannel','channel','imagingTTL','duration',p.flashTime,'value','High'});...%Cooling on
p.s.run();
%

%
imageViewer(r.images{1}(:,:,:))
figure;imagesc(r.images{1}(450:700,650:950,2)./r.images{1}(450:700,650:950,1))
