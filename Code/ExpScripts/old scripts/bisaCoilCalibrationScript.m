% Bias coil calibration script
%Initialize
clear all
imaqreset
basicImports;
pixCam=pixelfly();
pixCam.src.E1ExposureTime_unit='us';
pixCam.src.E2ExposureTime=3000;
pixCam.src.B1BinningHorizontal='04';
pixCam.src.B2BinningVertical='04';
thCam=Thorcam(100);
thCam.startLiveMode;

BiasPsu1=BiasPSU('TCPIP::10.10.10.106::inst0::INSTR'); %Y bias coils on Chan 1, Z Bias coil on Chan 2
BiasPsu2=BiasPSU('TCPIP::10.10.10.107::inst0::INSTR'); %X Bias coil on Chan 2

BiasPsu1.setOutput(1,1);
BiasPsu1.setOutput(2,1);
BiasPsu2.setOutput(2,1);
BiasPsu1.setCurrent(1,0);
BiasPsu1.setCurrent(2,0);
BiasPsu2.setCurrent(2,0);


% take a bg image with light on but magnetic field off
seqUpload(LoadMotSeq(channelTable));
setAHHCurrent(channelTable,'circ',0);
pause(2);
PixCamBgimg=pixCam.snapshot;
ThCamBgimg=thCam.getImage;

%save params
params.coolingPower='107mw'; %per beam
params.repumpPower='32mW';
params.coolingDet='-4.9'; %Gamma
params.repumpDet='5'; %Gamma
params.exposureTime=pixCam.src.E2ExposureTime;
params.Idisp='4A';
PixCamImSize=size(PixCamBgimg);
ThCamImSize=size(ThCamBgimg);

PixCamScale=4.32e-5; %m/pixel
ThCamScale=2.35e-5; %m/pixel;

PixCamX=linspace(-PixCamImSize(1)/2,PixCamImSize(1)/2,PixCamImSize(1))*PixCamScale;
PixCamY=linspace(-PixCamImSize(2)/2,PixCamImSize(2)/2,PixCamImSize(2))*PixCamScale;

ThCamX=linspace(-ThCamImSize(1)/2,ThCamImSize(1)/2,ThCamImSize(1))*ThCamScale;
ThCamY=linspace(-ThCamImSize(2)/2,ThCamImSize(2)/2,ThCamImSize(2))*ThCamScale;


%%
seqUpload(LoadMotSeq(channelTable));

%% Find MOT center at low field gradient and at high field gradient (in both cams)

% %first at low gradient
% setAHHCurrent(channelTable,'circ',50);
% pause(2);
% thCamImageLow=thCam.getImage;
% 
% pixCamImageLow=pixCam.snapshot;
% 
% [pThorLow,fitThorCamLow]=fitImageGaussian2D(ThCamX,ThCamY,thCamImageLow-ThCamBgimg);
% 
% [pPixLow,fitPixCamLow]=fitImageGaussian2D(PixCamX,PixCamY,pixCamImageLow-PixCamBgimg);
% 
% 
% pause(0.5);
% %first at low gradient
% setAHHCurrent(channelTable,'circ',220);
% pause(2);
% thCamImageHigh=thCam.getImage;
% pixCamImageHigh=pixCam.snapshot;
% [pThorHigh,fitThorCamHigh]=fitImageGaussian2D(ThCamX,ThCamY,thCamImageHigh-ThCamBgimg);
% [pPixHigh,fitPixCamHigh]=fitImageGaussian2D(PixCamX,PixCamY,pixCamImageHigh-PixCamBgimg);
% 
% %%
% 
% figure;
% subplot(2,2,1);
% hold on;
% imagesc(PixCamY,PixCamX,pixCamImageLow);
% plot(pPixLow(4),pPixLow(3),'Xr')
% title('Pixelfly low gradient');
% 
% subplot(2,2,2);
% hold on;
% imagesc(ThCamY,ThCamX,thCamImageLow);
% plot(pThorLow(4),pThorLow(3),'Xr')
% title('Thorcam low gradient');
% 
% subplot(2,2,4);
% hold on;
% imagesc(ThCamY,ThCamX,thCamImageHigh);
% plot(pThorHigh(4),pThorHigh(3),'Xr')
% title('Thorcam High gradient');
% 
% subplot(2,2,3);
% hold on;
% imagesc(PixCamY,PixCamX,pixCamImageHigh);
% plot(pPixHigh(4),pPixHigh(3),'Xr')
% title('Pixelfly High gradient');

%%
% figure
% subplot(1,2,1);
% hold on
% imagesc(PixCamY,PixCamX,pixCamImageHigh+pixCamImageLow-PixCamBgimg.*2);
% line([pPixLow(4),pPixHigh(4)],[pPixLow(3),pPixHigh(3)],'LineWidth',2,'Color','k');
% title('superimposed pixcam images (high/low gradient)');
% 
% subplot(1,2,2);
% hold on
% imagesc(ThCamY,ThCamX,thCamImageHigh+thCamImageLow-ThCamBgimg.*2);
% title('superimposed thorcam images (high/low gradient)');
% line([pThorHigh(4),pThorLow(4)],[pThorHigh(3),pThorLow(3)],'LineWidth',2,'Color','k');




%% y axis scan
NumSteps=20;
    BiasPsu1.setCurrent(1,0);
    BiasPsu1.setCurrent(2,0);
    BiasPsu2.setCurrent(2,0);
currentValsY=linspace(0.05,0.20,NumSteps);
%
% for ind=1:NumSteps
%    BiasPsu1.setCurrent(2,currentVals(ind));
%    pause(2);
%    Zimages(:,:,ind)=pixCam.snapshot;
%    [Zp(:,ind),ZfitImages(:,:,ind)]=fitImageGaussian2D(PixCamX,PixCamY,Zimages(:,:,ind));
% end


for ind=1:NumSteps
    %scan Y axis bias. BiasPSU1, Chan 1
    setAHHCurrent(channelTable,'circ',50);
    BiasPsu1.setCurrent(1,currentValsY(ind));
    pause(2);
    
    YimagesPixCamLow(:,:,ind)=pixCam.snapshot;
    YimagesThCamLow(:,:,ind)=thCam.getImage;
    
    [YpPixCamLow(:,ind),YfitImagesPixCamLow(:,:,ind)]=fitImageGaussian2D(PixCamX,PixCamY,YimagesPixCamLow(:,:,ind)-PixCamBgimg);
    [YpThCamLow(:,ind),YfitImagesThCamLow(:,:,ind)]=fitImageGaussian2D(ThCamX,ThCamY,YimagesThCamLow(:,:,ind)-ThCamBgimg);
    pause(0.5);
    setAHHCurrent(channelTable,'circ',220);
    pause(2);
    YimagesPixCamHigh(:,:,ind)=pixCam.snapshot;
    YimagesThCamHigh(:,:,ind)=thCam.getImage;
    
    [YpPixCamHigh(:,ind),YfitImagesPixCamHigh(:,:,ind)]=fitImageGaussian2D(PixCamX,PixCamY,YimagesPixCamHigh(:,:,ind)-PixCamBgimg);
    [YpThCamHigh(:,ind),YfitImagesThCamHigh(:,:,ind)]=fitImageGaussian2D(ThCamX,ThCamY,YimagesThCamHigh(:,:,ind)-ThCamBgimg);
end

%
% figure
% for ind=1:NumSteps
%     numCol=2;
%     numRow=ceil(2*NumSteps/numCol);
%     subplot(numRow,numCol,2*ind-1);
%     hold on
%     imagesc(PixCamY,PixCamX,YimagesPixCamHigh(:,:,ind)+YimagesPixCamLow(:,:,ind)-PixCamBgimg.*2);
%     %line([YpPixCamLow(4,ind),YpPixCamHigh(4,ind)],[YpPixCamLow(3,ind),YpPixCamHigh(3,ind)],'LineWidth',1,'Color','k');
%     title('superimposed pixcam images (high/low gradient)');
%     axis square
%     subplot(numRow,numCol,2*ind);
%     hold on
%     imagesc(ThCamY,ThCamX,YimagesThCamHigh(:,:,ind)+YimagesThCamLow(:,:,ind)-ThCamBgimg.*2);
%     title('superimposed thorcam images (high/low gradient)');
%     %line([YpThCamHigh(4,ind),YpThCamLow(4,ind)],[YpThCamHigh(3,ind),YpThCamLow(3,ind)],'LineWidth',1,'Color','k');
%     
%     xlabel('x [m]');
%     ylabel('y [m]');
%     axis square
%     title(sprintf('I_y = %d [A]',currentVals(ind)));
% end

%% Z axis scan 

NumSteps=20;
    BiasPsu1.setCurrent(1,0);
    BiasPsu1.setCurrent(2,0);
    BiasPsu2.setCurrent(2,0);
currentValsZ=linspace(0.2,0.3,NumSteps);
%
% for ind=1:NumSteps
%    BiasPsu1.setCurrent(2,currentVals(ind));
%    pause(2);
%    Zimages(:,:,ind)=pixCam.snapshot;
%    [Zp(:,ind),ZfitImages(:,:,ind)]=fitImageGaussian2D(PixCamX,PixCamY,Zimages(:,:,ind));
% end


for ind=1:NumSteps
    %scan Z axis bias. BiasPSU1, Chan 1
    setAHHCurrent(channelTable,'circ',50);
    BiasPsu1.setCurrent(2,currentValsZ(ind));
    pause(2);
    
    ZimagesPixCamLow(:,:,ind)=pixCam.snapshot;
    ZimagesThCamLow(:,:,ind)=thCam.getImage;
    
    [ZpPixCamLow(:,ind),ZfitImagesPixCamLow(:,:,ind)]=fitImageGaussian2D(PixCamX,PixCamY,ZimagesPixCamLow(:,:,ind)-PixCamBgimg);
    [ZpThCamLow(:,ind),ZfitImagesThCamLow(:,:,ind)]=fitImageGaussian2D(ThCamX,ThCamY,ZimagesThCamLow(:,:,ind)-ThCamBgimg);
    pause(0.5);
    setAHHCurrent(channelTable,'circ',220);
    pause(2);
    ZimagesPixCamHigh(:,:,ind)=pixCam.snapshot;
    ZimagesThCamHigh(:,:,ind)=thCam.getImage;
    
    [ZpPixCamHigh(:,ind),ZfitImagesPixCamHigh(:,:,ind)]=fitImageGaussian2D(PixCamX,PixCamY,ZimagesPixCamHigh(:,:,ind)-PixCamBgimg);
    [ZpThCamHigh(:,ind),ZfitImagesThCamHigh(:,:,ind)]=fitImageGaussian2D(ThCamX,ThCamY,ZimagesThCamHigh(:,:,ind)-ThCamBgimg);
end

%
% figure
% for ind=1:NumSteps
%     numCol=2;
%     numRow=ceil(2*NumSteps/numCol);
%     subplot(numRow,numCol,2*ind-1);
%     hold on
%     imagesc(PixCamY,PixCamX,ZimagesPixCamHigh(:,:,ind)+ZimagesPixCamLow(:,:,ind)-PixCamBgimg.*2);
%     %line([YpPixCamLow(4,ind),YpPixCamHigh(4,ind)],[YpPixCamLow(3,ind),YpPixCamHigh(3,ind)],'LineWidth',1,'Color','k');
%     title('superimposed pixcam images (high/low gradient)');
%     axis square
%     subplot(numRow,numCol,2*ind);
%     hold on
%     imagesc(ThCamY,ThCamX,ZimagesThCamHigh(:,:,ind)+ZimagesThCamLow(:,:,ind)-ThCamBgimg.*2);
%     title('superimposed thorcam images (high/low gradient)');
%     %line([YpThCamHigh(4,ind),YpThCamLow(4,ind)],[YpThCamHigh(3,ind),YpThCamLow(3,ind)],'LineWidth',1,'Color','k');
%     
%     xlabel('x [m]');
%     ylabel('y [m]');
%     axis square
%     title(sprintf('I_Z = %d [A]',currentVals(ind)));
% end
setAHHCurrent(channelTable,'circ',0);

%% X axis scans
NumSteps=20;
%make sure Y and Z bias field are 0
    BiasPsu1.setCurrent(1,0);
    BiasPsu1.setCurrent(2,0);
    BiasPsu2.setCurrent(2,0);
currentValsX=linspace(-0.11,-0.01,NumSteps);
%
% for ind=1:NumSteps
%    BiasPsu1.setCurrent(2,currentVals(ind));
%    pause(2);
%    Zimages(:,:,ind)=pixCam.snapshot;
%    [Zp(:,ind),ZfitImages(:,:,ind)]=fitImageGaussian2D(PixCamX,PixCamY,Zimages(:,:,ind));
% end


for ind=1:NumSteps
    %scan X axis bias. BiasPSU1, Chan 1
    setAHHCurrent(channelTable,'circ',50);
    BiasPsu2.setCurrent(2,currentValsX(ind));
    pause(2);
    
    XimagesPixCamLow(:,:,ind)=pixCam.snapshot;
    XimagesThCamLow(:,:,ind)=thCam.getImage;
    
    [XpPixCamLow(:,ind),XfitImagesPixCamLow(:,:,ind)]=fitImageGaussian2D(PixCamX,PixCamY,XimagesPixCamLow(:,:,ind)-PixCamBgimg);
    [XpThCamLow(:,ind),XfitImagesThCamLow(:,:,ind)]=fitImageGaussian2D(ThCamX,ThCamY,XimagesThCamLow(:,:,ind)-ThCamBgimg);
    pause(0.5);
    setAHHCurrent(channelTable,'circ',220);
    pause(2);
    XimagesPixCamHigh(:,:,ind)=pixCam.snapshot;
    XimagesThCamHigh(:,:,ind)=thCam.getImage;
    
    [XpPixCamHigh(:,ind),XfitImagesPixCamHigh(:,:,ind)]=fitImageGaussian2D(PixCamX,PixCamY,XimagesPixCamHigh(:,:,ind)-PixCamBgimg);
    [XpThCamHigh(:,ind),XfitImagesThCamHigh(:,:,ind)]=fitImageGaussian2D(ThCamX,ThCamY,XimagesThCamHigh(:,:,ind)-ThCamBgimg);
end

%
% figure
% for ind=1:NumSteps
%     numCol=2;
%     numRow=ceil(2*NumSteps/numCol);
%     subplot(numRow,numCol,2*ind-1);
%     hold on
%     imagesc(PixCamY,PixCamX,XimagesPixCamHigh(:,:,ind)+XimagesPixCamLow(:,:,ind)-PixCamBgimg.*2);
%     %line([YpPixCamLow(4,ind),YpPixCamHigh(4,ind)],[YpPixCamLow(3,ind),YpPixCamHigh(3,ind)],'LineWidth',1,'Color','k');
%     title('superimposed pixcam images (high/low gradient)');
%     axis square
%     subplot(numRow,numCol,2*ind);
%     hold on
%     imagesc(ThCamY,ThCamX,XimagesThCamHigh(:,:,ind)+XimagesThCamLow(:,:,ind)-ThCamBgimg.*2);
%     title('superimposed thorcam images (high/low gradient)');
%     %line([YpThCamHigh(4,ind),YpThCamLow(4,ind)],[YpThCamHigh(3,ind),YpThCamLow(3,ind)],'LineWidth',1,'Color','k');
%     
%     xlabel('x [m]');
%     ylabel('y [m]');
%     axis square
%     title(sprintf('I_X = %d [A]',currentVals(ind)));
% end
% customsave(mfilename)
%%
% BiasPsu1.setCurrent(1,0.1);
% BiasPsu1.setCurrent(2,0.25);
% setAHHCurrent(channelTable,'circ',50);
% pause(0.5)
% compImLow=pixCam.snapshot;
% setAHHCurrent(channelTable,'circ',220);
% pause(2)
% compImHigh=pixCam.snapshot;
% figure;
% suptitle('YZ Plane magnetic field compenastion images')
% subplot(1,3,1);
% imagesc(PixCamY,PixCamX,compImHigh+compImLow-2.*PixCamBgimg)
% axis square
% xlabel('Y');
% ylabel('Z');
% title('superimposed high/low images')
% subplot(1,3,2);
% imagesc(PixCamY,PixCamX,compImHigh-PixCamBgimg)
% title('High gradient cloud')
% axis square
% xlabel('Y');
% ylabel('Z');
% subplot(1,3,3);
% imagesc(PixCamY,PixCamX,compImLow-PixCamBgimg)
% title('Low gradient cloud')
% axis square
% xlabel('Y');
% ylabel('Z');
% 
%% compensation verification X,Y,Z

BiasPsu1.setCurrent(1,0.1211);
BiasPsu1.setCurrent(2,0.2);
BiasPsu2.setCurrent(2,-0.05211);
setAHHCurrent(channelTable,'circ',50);
pause(0.5)
PixcompImLow=pixCam.snapshot;
ThcompImLow=thCam.getImage;
setAHHCurrent(channelTable,'circ',220);
pause(2)
PixcompImHigh=pixCam.snapshot;
ThcompImHigh=thCam.getImage;

figure;
suptitle('XYZ field compensation')
subplot(1,2,1);
imagesc(PixCamY,PixCamX,PixcompImHigh+PixcompImLow-2.*PixCamBgimg)
axis square
xlabel('Y');
ylabel('Z');
title('YZ plane')
subplot(1,2,2);
imagesc(ThCamX,ThCamY,ThcompImHigh+ThcompImLow-2.*ThCamBgimg)
title('YX plane')
xlabel('X');
ylabel('Y');

axis square

% customsave()

% figure
% for ind=1:NumSteps
%     numCol=4;
%     numRow=ceil(NumSteps/numCol);
%     subplot(numRow,numCol,ind);
%     imagesc(PixCamX,PixCamY,Zimages(:,:,ind)-bgimg);
%     xlabel('x [m]');
%     ylabel('y [m]');
%     axis square
%     title(sprintf('I_z= %d [A]',currentVals(ind)));
% end
% figure;
% hold on
% plot(currentVals,Zp(3,:),'or');
% plot(currentVals,Zp(4,:),'ok');
% legend({'y cent pos','z cent pos'});
% title('center position with Z bias coil current')


%
%
% % %%
% % figure
% % for ind=1:NumSteps
% %     numCol=4;
% %     numRow=ceil(NumSteps/numCol);
% %     subplot(numRow,numCol,ind);
% %     imagesc(x,y,YfitImages(:,:,ind));
% %     axis square
% %     xlabel('x [m]');
% %     ylabel('y [m]');
% %     title(sprintf('I_y=%.2f[A],y_0=%d [m]',currentVals(ind),p(3,ind)));
% % end
%
% % figure;
% % hold on
% % plot(currentVals,Yp(3,:),'or');
% % plot(currentVals,Yp(4,:),'ok');
% % legend({'y cent pos','x cent pos'});
% % title('center position with Y bias coil current')
% %%%
%% Ploting
%Pixelfly diffs
difYPixY = YpPixCamHigh(3,:) - YpPixCamLow(3,:);
difYPixZ = YpPixCamHigh(4,:) - YpPixCamLow(4,:);

difZPixY = ZpPixCamHigh(3,:) - ZpPixCamLow(3,:);
difZPixZ = ZpPixCamHigh(4,:) - ZpPixCamLow(4,:);

difXPixY = XpPixCamHigh(3,:) - XpPixCamLow(3,:);
difXPixZ = XpPixCamHigh(4,:) - XpPixCamLow(4,:);

%Thorcam diffs
difYThCamX = YpThCamHigh(3,:) - YpThCamLow(3,:);
difYThCamY = YpThCamHigh(4,:) - YpThCamLow(4,:);

difZThCamX = ZpThCamHigh(3,:) - ZpThCamLow(3,:);
difZThCamY = ZpThCamHigh(4,:) - ZpThCamLow(4,:);

difXThCamX = XpThCamHigh(3,:) - XpThCamLow(3,:);
difXThCamY = XpThCamHigh(4,:) - XpThCamLow(4,:);

%Pixelfly figure
figure;
subplot(3,2,1)
plot(currentValsY,difYPixY,'o-');
title('Y bias scan y center position');

subplot(3,2,2)
plot(currentValsY,difYPixZ,'o-');
title('Y bias scan z center position');

subplot(3,2,3)
plot(currentValsZ,difZPixY,'o-');
title('Z bias scan y center position');

subplot(3,2,4)
plot(currentValsZ,difZPixZ,'o-');
title('Z bias scan z center position');

subplot(3,2,5)
plot(currentValsX,difXPixY,'o-');
title('X bias scan y center position');

subplot(3,2,6)
plot(currentValsX,difXPixZ,'o-');
title('X bias scan z center position');
suptitle('Pixelfly diff scan')

%ThorCam figure
figure;
subplot(3,2,1)
plot(currentValsY,difYThCamX,'o-');
title('Y bias scan x center position');

subplot(3,2,2)
plot(currentValsY,difYThCamY,'o-');
title('Y bias scan y center position');

subplot(3,2,3)
plot(currentValsZ,difZThCamX,'o-');
title('Z bias scan x center position');

subplot(3,2,4)
plot(currentValsZ,difZThCamY,'o-');
title('Z bias scan y center position');

subplot(3,2,5)
plot(currentValsX,difXThCamX,'o-');
title('X bias scan x center position');

subplot(3,2,6)
plot(currentValsX,difXThCamY,'o-');
title('X bias scan y center position');
suptitle('THorcam diff scan')

%%
customsave(mfilename)

%%
% 
% figure
% for ind=1:NumSteps
%     numCol=4;
%     numRow=ceil(NumSteps/numCol);
%     subplot(numRow,numCol,ind);
%     imagesc(ThCamX,ThCamY,YfitImagesThCamHigh(:,:,ind)+YfitImagesThCamLow(:,:,ind)-2*ThCamBgimg);
%     xlabel('x [m]');
%     ylabel('y [m]');
%     axis square
%     title(sprintf('I_z= %d [A]',currentValsY(ind)));
% end
