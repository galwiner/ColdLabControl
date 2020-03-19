%scanning tisaph 
%we need to be able to get the tisaph working params to be able to
%intrepret the results fully.
%We scan the ti:saff and take an image of the MOT.
clear all
basicImports;
params.Icirc = 100;
params.Irect = 0;
params.Idis = 4.1;

 seqUpload(LoadMotSeq(channelTable));
 nsteps=1000;
voltageList=linspace(0,5,nsteps);
pixCam=pixelfly();
pixCam.src.E1ExposureTime_unit='us';
pixCam.src.E2ExposureTime=1000;
pixCam.src.B1BinningHorizontal='04';
pixCam.src.B2BinningVertical='04';
format long
for ind=1:nsteps
    seqUpload(TiSaphTuneSeq(channelTable,0,voltageList(ind)));
    pause(0.1)
    images(:,:,ind) = pixCam.snapshot;
    wlmread=getWavelengths();
    tiSaph(ind)=wlmread(6);
    pause(1)
end

figure;
plot(voltageList,tiSaph,'o-'); 
xlabel('Analog Chan Voltage [V]');
ylabel('WLM readout [THz]');
seqUpload(TiSaphTuneSeq(channelTable,0,0));

scale=4.32e-5; %m/pixel
imsize=size(images(:,:,1));
x=linspace(-imsize(1)/2,imsize(1)/2,imsize(1))*scale;
y=linspace(-imsize(2)/2,imsize(2)/2,imsize(2))*scale;


for ind=1:nsteps
   [p(:,ind),fitimages(:,:,ind)]=fitImageGaussian2D(x,y,images(:,:,ind));
end

figure;
plot(tiSaph,p(7,:),'o-');


customsave(mfilename)