%L.D. 26.11
%This script takes pictures of optical molasses.

clear all
imaqreset
basicImports;

pixCam=pixelfly();
pixCam.src.E1ExposureTime_unit='us';
pixCam.src.E2ExposureTime=200;
pixCam.src.B1BinningHorizontal='04';
pixCam.src.B2BinningVertical='04';

% take a bg image with light on but magnetic field off
% seqUpload(LoadMotSeq(channelTable));
% setAHHCurrent(channelTable,'circ',0);
% pause(2);
bgImg=takeBGImg(channelTable,'pixelfly',pixCam);

scale=4.32e-5; %m/pixel
% imsize= [260 , 348];
imsize=size(bgImg);
x=linspace(-imsize(1)/2,imsize(1)/2,imsize(1))*scale;
y=linspace(-imsize(2)/2,imsize(2)/2,imsize(2))*scale;

params.coolingPower='85mw'; %per beam
params.repumpPower='15mW';
params.coolingDet='-4.9'; %Gamma
params.repumpDet='0'; %Gamma
params.exposureTime=pixCam.src.E2ExposureTime;
params.Idisp='4A';
params.Waveplate1pos=125;
params.Waveplate2pos=221;
% params.delayList=[200,1000,2000,3000,4000]; %times for the TOF flights in microseconds
params.delayList=[200,3000]; %times for the TOF flights in microseconds
sizeIm= [260 , 348];%size(bgimg);
NTOFimages=length(params.delayList); %how many images are we taking?

delay=params.delayList; %in microseconds
motLoadTime=2e6; %4 seconds

pixCam.setHardwareTrig(1)



for ind=1:length(delay)
    pixCam.start;
    disp(delay(ind));
    seqUpload(LoadMotSeq(channelTable));
    pause(motLoadTime*1e-6);
    
    seqUpload(horzcat(MollassesSeq(channelTable,0,delay(ind)),...
        {Pulse(channelTable.PhysicalName{'pixelfly'},delay(ind)-pixCam.src.E2ExposureTime-5.6,20)}));
    pause(0.5);
    
end
images=pixCam.getImages(NTOFimages);
pixCam.stop;

figure;
for ind=1:NTOFimages
    numCol=2;
    numRow=ceil(NTOFimages/numCol);
    subplot(numRow,numCol,ind);
    imagesc(x,y,images(:,:,ind));
    xlabel('x [m]');
    ylabel('y [m]');
    axis square
    title(['delay = ' num2str(delay(ind)) '[\muS]']);
end

figure
for ind=1:NTOFimages
    numCol=2;
    numRow=ceil(NTOFimages/numCol);
    subplot(numRow,numCol,ind);
    [p(:,ind),fitImages(:,:,ind)]=fitImageGaussian2D(x,y,images(:,:,ind)-bgImg);
    imagesc(x,y,fitImages(:,:,ind));
    
    xlabel('x [m]');
    ylabel('y [m]');
    axis square
    title(['delay = ' num2str(delay(ind)) '[\muS]']);
end
suptitle(sprintf("delta_z = %.2e \n delta_y=%.2e",p(3,1)-p(3,2),p(4,1)-p(4,2)));

customsave(mfilename);