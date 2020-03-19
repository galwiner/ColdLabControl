clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Absorption Image Detuning Scan';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=2;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.absImg{1} = 1;
p.cameraParams{1}.B1BinningHorizontal = '04';
p.cameraParams{1}.B2BinningVertical = '04';
p.cameraParams{1}.E2ExposureTime=1e3;
% p.cameraParams{1}.ROI = [600,400,600,400];
p.cameraParams{1}.ROI = [120,0,160,240];
p.fitWidthHight =[1e-4,1e-4];
% p.imagingPower = 50;
initinst
initr
%%  
% p.MOTReleaseTime = 1e3;
p.imagingPower = 30;
p.AbsImgTime = 10;
p.flashTime = p.AbsImgTime;
% nsteps = 5;
% imageingPowerVals = linspace(10,60,nsteps);
p.flashPause = 6;
p.MOTLoadTime = 2e6;
p.loopVals{1} =linspace(0,0,1);
p.loopVars{1} = 'imagingDetuning';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.pauseBetweenImages = 200e3;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','imagingTTL','duration',0,'value','low'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',40e3});
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'Load MOT'});
% % p.s.addBlock({'setCoolingDetuning','duration',0,'value',-60});
p.s.addBlock({'setCoolingPower','value',15,'duration',0});
p.s.addBlock({'setRepumpPower','value',0.05,'duration',0});
p.s.addBlock({'pause','duration',40e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',2e3});
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'GenPause','duration',100e3})
% p.s.addBlock({'setImagingPower','channel','ImagingVVAN','duration',0,'value',p.imagingPower,'description','set imaging power'});
% p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High','description','picture:trigger photo'});%Trigger camera
% p.s.addBlock({'pause','duration',p.flashPause});%pixelfly intrinsic delay
% p.s.addBlock({'setDigitalChannel','channel','imagingTTL','duration',p.flashTime,'value','High'});...%Cooling on
p.s.run();
%
imageViewer(r.images{1}(:,:,:))
%%
% imageViewer(r.images{1}(:,:,:))
% ODs = r.fitParams{1}(1,:);
% widths = r.fitParams{1}(4,:);
% hights = r.fitParams{1}(5,:);
% figure;
% subplot(3,1,1)
% plot(p.loopVals{1},ODs)
% subplot(3,1,2)
% plot(p.loopVals{1},widths)
% hold on
% plot(p.loopVals{1},hights)
% subplot(3,1,3)
% plot(p.loopVals{1},r.fitParams{1}(6,:))
xcent = 87;
ycent = 152;
xCuts = squeeze(r.normIms{1}(ycent,:,:))';
yCuts = squeeze(r.normIms{1}(:,xcent,:))';
figure;
subplot(2,1,1)
% surf(yCuts)
plot(r.y{1},yCuts)
hold on
plot(r.y{1},r.fitImages{1}(:,xcent))
subplot(2,1,2)
plot(r.x{1},xCuts)
hold on
plot(r.x{1},r.fitImages{1}(ycent,:))

% surf(xCuts)
