clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasTTresults = 0;
p.ttDumpMeasurement = 0;
p.hasPicturesResults=1;
p.picsPerStep = 2;
p.pfLiveMode=0;
p.tcLiveMode=1;
% p.idsMonitor = 1;

p.cameraParams{1}.B1BinningHorizontal='04';
p.cameraParams{1}.B2BinningVertical='04';
% p.cameraParams{1}.ROI=[180, 120,50, 50];
p.cameraParams{1}.ROI=[100, 90,120, 120];
initinst
initr
p.MOTLoadTime=8e6;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'Load MOT'});
p.s.runStep
p.expName = 'Hole depth spectroscopy';


inst.BiasFieldManager.I=[0.0300   -0.0850    0.0900]; %B field values to center MOT on camera
p.runSettlingLoop=0;
%%

% p.cameraParams{1}
p.flashTime=20;
p.BLUE_HOLE_Time = 1e3;
p.MOTReloadTime = 4e5;

p.NAverage=1;
p.nInner = 60;
p.loopVals{1}=linspace(RydbergDet2synthHDFreq(-60),RydbergDet2synthHDFreq(60),p.nInner);
resetControlLock(p.loopVals{1}(1));
p.loopVars{1} = 'TS_Detuning';
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.hole_TOF_Time=1;
p.tofTime = 2e3;
resetControlLock(p.loopVals{1}(1));
p.s=sqncr();
p.s.addBlock({p.asyncActions.setSynthHDFreq,'channel','A','freq',p.TS_Detuning});
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.coolingSwitch,'value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.repumpSwitch,'value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'pause','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.coolingSwitch,'value','high','duration',p.hole_TOF_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.repumpSwitch,'value','high','duration',p.hole_TOF_Time});
p.s.addBlock({'pause','duration',p.hole_TOF_Time});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({p.compoundActions.TakePicWithCooling})
p.s.addBlock({p.atomicActions.pause,'duration',10e3});
p.s.addBlock({p.compoundActions.ReloadMOT})
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.coolingSwitch,'value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.repumpSwitch,'value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'pause','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.coolingSwitch,'value','high','duration',p.hole_TOF_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.repumpSwitch,'value','high','duration',p.hole_TOF_Time});
p.s.addBlock({'pause','duration',p.hole_TOF_Time});
p.s.addBlock({p.compoundActions.TakePicWithCooling})
p.s.addBlock({p.atomicActions.pause,'duration',10e3});
p.s.addBlock({p.compoundActions.ReloadMOT})
p.s.run();



%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)

figure;
for ii = 1:p.nInner
    subplot(2,length(p.loopVals{1}),ii)
imagesc(mean(r.images{1}(:,:,1,1,ii,:),6))
colorbar
subplot(2,length(p.loopVals{1}),ii+p.nInner)
imagesc(mean(r.images{1}(:,:,2,1,ii,:),6))
colorbar
end

meanIms_ref = squeeze(mean(r.images{1},6));
% meanIms_ref = movmean(meanIms_ref,10,1);
% meanIms_ref = movmean(meanIms_ref,10,2);
meanIms_ref_norm = zeros(size(meanIms_ref));
for jj = 1:size(meanIms_ref,4)
    for ii = 1:size(meanIms_ref,3)    
        tmpIm = meanIms_ref(:,:,ii,jj);
        meanIms_ref_norm(:,:,ii,jj) = tmpIm/max(tmpIm(:));
    end
end
% figure;
% imageViewer(meanIms_ref_norm(:,:,1,:)./meanIms_ref_norm(:,:,2,:))
% [pf,gof,fit_img]=fitImageGaussian2D([],[],r.images{1}(:,:,2)./r.images{1}(:,:,1));
% figure
% imagesc(fit_img)
meanIms_ref=nanmean(r.images{1}(:,:,2,:,:,:),6);
meanIms_hole=nanmean(r.images{1}(:,:,1,:,:,:),6);
meanIms_normed=squeeze(meanIms_ref./meanIms_hole);
imageViewer(meanIms_normed)
% sigmax=[];
% sigmay=[];
% depth=[];
pf=[];
fit_ims=zeros(size(meanIms_normed));
p.GaussianFitThreshold=0.2;
for ind=1:p.nInner
[pf(ind,:),gof,fit_ims(:,:,ind)]=fitImageGaussian2D([],[],meanIms_normed(:,:,ind));
end
depth=pf(:,2);
sigmax=pf(:,5);
sigmay=pf(:,6);
hole_int=pf(:,7);

figure;
subplot(1,2,1)
plot(p.loopVals{1},sigmax,'-ob','DisplayName','\sigma_x')
hold on
plot(p.loopVals{1},sigmay,'-or','DisplayName','\sigma_y')
legend
xlabel('Blue freq. [MHZ]')
ylabel('pixels')
title(sprintf('Hole size N_{avg}=%d',p.NAverage))
subplot(1,2,2)
yyaxis left
plot(p.loopVals{1},depth,'-o');
ylabel('depth')
yyaxis right
plot(p.loopVals{1},hole_int,'-o');
ylabel('sum over hole')

xlabel('Blue freq. [MHZ]')

title('hole dpeth')
% subplot(2,1,1)
% imagesc(meanIms_normed)
% subplot(2,1,2)
% imagesc(fit_img)


%%
% fh = figure();
% fh.WindowState = 'maximized';
% vidName='hole_formation.avi';
% writerObj=VideoWriter(vidName);
% writerObj.FrameRate=5;
% open(writerObj);
% for ind=1:size(meanIms_ref_norm,4)
%     
% %     frame=im2frame(rescale(-(meanIms_norm(:,:,ind)-meanIms_ref_norm(:,:,ind)),1,256),parula((256)));
%     imagesc(meanIms_ref_norm(:,:,1,ind)./meanIms_ref_norm(:,:,2,ind));
% %     text(90,120,sprintf('T=%.1f uS',p.loopVals{1}(ind)),'FontSize',14,'Color','Black','BackgroundColor','White');
%     title(sprintf('Time from Blue on =%.1f uS',p.loopVals{1}(ind)),'FontSize',20);
%     colorbar
%     frame=getframe(gcf);
% %     frame=im2frame(insertText(rescale((meanIms(:,:,ind)),1,256),parula((256)),[50;50],'this') );
%     writeVideo(writerObj,frame);
% end
% 
% close(writerObj);
% implay(vidName)
