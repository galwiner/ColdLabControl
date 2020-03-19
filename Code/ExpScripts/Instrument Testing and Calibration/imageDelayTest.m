clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='image delay test';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=0;
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
p.imagingPower = 700;
p.flashTime = 1;
% p.flashPause = 26;
p.loopVals{1} =linspace(1,10,10);
p.loopVars{1} = 'flashPause';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'setImagingPower','channel','ImagingVVAN','duration',0,'value',p.imagingPower,'description','set imaging power'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High','description','picture:trigger photo'});%Trigger camera
p.s.addBlock({'pause','duration',p.flashPause});%pixelfly intrinsic delay
p.s.addBlock({'setDigitalChannel','channel','imagingTTL','duration',p.flashTime,'value','High'});...%Cooling on
p.s.addBlock({'pause','duration',300e3})
p.s.run();
%

%
imageViewer(r.images{1}(:,:,:))