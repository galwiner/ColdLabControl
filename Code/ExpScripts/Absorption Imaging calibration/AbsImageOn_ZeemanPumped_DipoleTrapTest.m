clear all
imaqreset
global p
global r
global inst
DEBUG=0;
initp
p.runAutoPlot=1;
p.expName='absorption image test';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=2;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=0;
p.absImagePostproc = 1;
p.absImg{1} = 1;
if p.picsPerStep == 1
    p.calcTemp = 0;
else
    p.calcTemp = 1;
end
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.ROIWidth = 200;
p.ROIHeight = 200;
p.cameraParams{1}.ROI = [p.DTPos{1}(1)-p.ROIWidth/2,p.DTPos{1}(2)-p.ROIHeight/2,p.ROIWidth,p.ROIHeight];
p.cameraParams{1}.E2ExposureTime=1e3;
p.absoImageCenter = [96,96];
initinst
initr
%%  
% p.MOTReleaseTime = 1e3;
p.runSettlingLoop = 1;
p.probeNDList = [13,3,2];
p.ZeemanNDList = [11];
p.zeemanRepumpND=[7]; %list with values of the ND filters used in the zeeman repump for this measurement
p.zeemanPumpPower=0.0027;
% p.zeemanPumpPower = 0.06;
p.zeemanRepumpPower=0.0056;
p.BiasField=-1+p.B0(2);
p.ZeemanPumpCycles = 40;
p.gateNum = 3e3;
p.gateTime = 20;
p.s = sqncr;
p.s.addBlock({p.asyncActions.setZeemanPumpPower,'value',p.zeemanPumpPower,'ND',p.ZeemanNDList});
p.s.addBlock({p.asyncActions.setZeemanRepumpPower,'value',p.zeemanRepumpPower,'ND',p.zeemanRepumpND});
p.s.runStep;
p.MagneticPulseTime=p.gateNum * (p.gateTime+2) + 30e3 ;
p.repumpTime = 100;

p.DTParams.MOTLoadTime = 0.75e6;
% p.DTParams.TrapTime = 7e4;
p.DTParams.TrapTime = 1;
p.AbsImgTime = 10;
p.pauseBetweenImages = 200e3;
p.loopVals{1} = linspace(1,1,1);
p.loopVars{1} = 'oscTime';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.tofTime = 1;
p.NAverage = 20;
p.s=sqncr();
p.s.addBlock({p.compoundActions.LoadDipoleTrapAndPump});
p.s.addBlock({'pause','duration',1e3})
p.s.addBlock({'pause','duration',p.oscTime})
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'pause','duration',1.5e3})
p.s.addBlock({'TrigScope'});

p.s.addBlock({'TakeAbsPicNoRepump'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.pauseBetweenImages});
p.s.addBlock({'TakeAbsPicNoRepump'});
p.s.addBlock({'pause','duration',p.pauseBetweenImages});
p.s.addBlock({p.compoundActions.resetSystem});
% p.s.addBlock({'GenPause','duration',10e3})
p.s.run();
%
x = inst.cameras('pixelfly').x;
y = inst.cameras('pixelfly').y;
r.x=x;
r.y=y;
if p.runAutoPlot==0
    return
end
%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
% x=r.x;
% y=r.y;
% figure
% subplot(2,2,1)
% imagesc(squeeze(r.images{1}(:,:,1)))
% colorbar
% subplot(2,2,2)
% imagesc(squeeze(r.images{1}(:,:,2)))
% colorbar
% subplot(2,2,3)
% imagesc(squeeze(r.AbsoImagesStack))
% hold on
% plot(p.absoImageCenter(1),p.absoImageCenter(2),'rx')
% hold off
% colorbar
% subplot(2,2,4)
% plot(r.absoImCrosses{1})
% hold on
% plot(r.absoImCrosses{2})
% hold off
% ylim([0 2])
figure;
% subplot(2,2,1)
% plot(p.loopVals{1},squeeze(mean(r.absImfp(1,:,:,1),3)))
% subplot(2,2,2)
% yyaxis left
% plot(p.loopVals{1},squeeze(mean(r.absImfp(1,:,:,4),3)))
% yyaxis right
% plot(p.loopVals{1},squeeze(mean(r.absImfp(1,:,:,6),3)))
% subplot(2,2,3)
% plot(p.loopVals{1},squeeze(mean(r.absImfp(1,:,:,5),3)))
% subplot(2,2,4)
% plot(p.loopVals{1},squeeze(mean(r.absImfp(1,:,:,7),3)))
subplot(2,2,1)
plot(squeeze(reshape(r.absImfp(1,:,:,1),[1,size(r.absImfp,2)*size(r.absImfp,3)])))
subplot(2,2,2)
yyaxis left
plot(squeeze(reshape(r.absImfp(1,:,:,4),[1,size(r.absImfp,2)*size(r.absImfp,3)])))
yyaxis right
plot(squeeze(reshape(r.absImfp(1,:,:,6),[1,size(r.absImfp,2)*size(r.absImfp,3)])))
subplot(2,2,3)
plot(squeeze(reshape(r.absImfp(1,:,:,5),[1,size(r.absImfp,2)*size(r.absImfp,3)])))
subplot(2,2,4)
plot(squeeze(reshape(r.absImfp(1,:,:,3),[1,size(r.absImfp,2)*size(r.absImfp,3)])))
