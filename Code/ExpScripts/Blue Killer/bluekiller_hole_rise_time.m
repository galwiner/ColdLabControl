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

p.cameraParams{1}.B1BinningHorizontal='01';
p.cameraParams{1}.B2BinningVertical='01';
% p.cameraParams{1}.ROI=[0, 0,900, 900];
initinst
initr
p.expName = 'Hole rize time measurement';
inst.BiasFieldManager.I=[0.0300   -0.0850    0.0900]; %B field values to center MOT on camera
% inst.DDS.setFreq(1,390);
%% 
% p.cameraParams{1}
p.flashTime=20;

p.runSettlingLoop=0;
p.MOTLoadTime=1e6;
p.NAverage=1;
p.loopVals{1}=linspace(2e2,2e2,1);
p.loopVars{1} = 'BLUE_HOLE_Time';
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.tofTime = 2e3;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'Load MOT'});
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.coolingSwitch,'value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.repumpSwitch,'value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'pause','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});

p.s.addBlock({p.compoundActions.TakePicWithCooling})
p.s.addBlock({p.atomicActions.pause,'duration',1e6});
p.s.addBlock({p.compoundActions.LoadMOT})
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.coolingSwitch,'value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.repumpSwitch,'value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'pause','duration',p.BLUE_HOLE_Time});
p.s.addBlock({p.compoundActions.TakePicWithCooling})
p.s.addBlock({p.atomicActions.pause,'duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();



%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
figure;
subplot(2,1,1)
imagesc(r.images{1}(:,:,1))
colorbar
subplot(2,1,2)
imagesc(r.images{1}(:,:,2))
colorbar


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
imageViewer(meanIms_ref_norm(:,:,1,:)./meanIms_ref_norm(:,:,2,:))

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
