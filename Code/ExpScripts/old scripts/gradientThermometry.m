% themometry for different circular coil currents scan
% thermometry without touching detuning of any beam, CW MOT


clear all
imaqreset
basicImports;
pixCam=pixelfly();
pixCam.src.E1ExposureTime_unit='us';
pixCam.src.E2ExposureTime=1500;
pixCam.src.B1BinningHorizontal='04';
pixCam.src.B2BinningVertical='04';
% take a bg image with light on but magnetic field off
seqUpload(LoadMotSeq(channelTable));
setAHHCurrent(channelTable,'circ',0);
pause(2);
bgimg=pixCam.snapshot;

scale=4.32e-5; %m/pixel
imsize=size(bgimg);
x=linspace(-imsize(1)/2,imsize(1)/2,imsize(1))*scale;
y=linspace(-imsize(2)/2,imsize(2)/2,imsize(2))*scale;

params.coolingPower='107mw'; %per beam
params.repumpPower='32mW';
params.coolingDet='-4.9'; %Gamma
params.repumpDet='5'; %Gamma
params.exposureTime=pixCam.src.E2ExposureTime;
params.Idisp='4A';
sizeIm=size(bgimg);

params.delayList=[1000,2000,2500]; %times for the TOF flights in microseconds
ncurrsteps=1;
params.currentVals=linspace(40,220,ncurrsteps);

NTOFimages=length(params.delayList); %how many images are we taking?

pixCam.setHardwareTrig(NTOFimages);

% images=zeros(sizeIm(1),sizeIm(2),NTOFimages); %prealocate image array

             
delay=params.delayList; %in microseconds
motLoadTime=4e6; %2 seconds

temperature=zeros(ncurrsteps,2);
for ind=1:length(params.currentVals)
    [tx,ty]=thermometryStep(channelTable,bgimg,pixCam,motLoadTime,delay,params.currentVals(ind))
    temperature(ind,:)=[tx,ty];
end

% for ind=1:NTOFimages
%     seqUpload(TOFseq(channelTable,'pixelfly',delay(ind),motLoadTime,pixCam.src.E2ExposureTime,100));
%     pause(motLoadTime*1e-6*2);
% end

% %%
% 
% %% extracting temperature
% 
% %% extract acceleration due to gravity g
% delayS=params.delayList*1e-6;
% figure;
% hold on
% plot(delayS,p(3,:),'or-');
% f1=fit(delayS',p(3,:)','poly2');
% plot(delayS,f1(delayS),'-');
% xlabel('t[s]');
% ylabel('z[m]');
% conf=confint(f1,0.95);
% title(sprintf('accleration due to gravity: %.2f +/- %.2f m/s^2',2*f1.p1,abs(2*conf(1,1)-2*f1.p1)))
% %%
% 


function [tempx,tempy]=thermometryStep(channelTable,bgimg,pixCam,motLoadTime,delay,current)
NTOFimages=length(delay);
scale=4.32e-5; %m/pixel
imsize=size(bgimg);
x=linspace(-imsize(1)/2,imsize(1)/2,imsize(1))*scale;
y=linspace(-imsize(2)/2,imsize(2)/2,imsize(2))*scale;

pixCam.start;

for ind=1:length(delay)
    disp(delay(ind));
    seqUpload(TOFseq(channelTable,'pixelfly',delay(ind),motLoadTime,pixCam.src.E2ExposureTime,current));
    pause(motLoadTime*1e-6*2);
end

images=pixCam.getImages(NTOFimages);

pixCam.stop;
figure
for ind=1:NTOFimages
    numCol=4;
    numRow=ceil(NTOFimages/numCol);
    subplot(numRow,numCol,ind);
    imagesc(x,y,images(:,:,ind)-bgimg);
    xlabel('x [m]');
    ylabel('y [m]');
    axis square
    title(sprintf('delay = %d [\mu S]',delay(ind)));
end

%%
figure
% fitImages=zeros(size(images));


for ind=1:NTOFimages
    numCol=4;
    numRow=ceil(NTOFimages/numCol);
    subplot(numRow,numCol,ind);
    [p(:,ind),fitImages(:,:,ind)]=fitImageGaussian2D(x,y,images(:,:,ind)-bgimg);
    imagesc(x,y,fitImages(:,:,ind));
    axis square
    xlabel('x [m]');
    ylabel('y [m]');
    title(sprintf('t=%d [uS],sx=%.2 m',delay(ind),p(5,ind)))
end




figure;
hold on

% T=consts.mrb*(0.2450)^2/consts.kb
delay=delay*1e-6;
fx=fit(delay'.^2,p(5,:)'.^2,'poly1');
fy=fit(delay'.^2,p(6,:)'.^2,'poly1');

plot(delay.^2,p(5,:).^2,'or')
plot(delay.^2,fx(delay.^2),'-r')

plot(delay.^2,p(6,:).^2,'ob')
plot(delay.^2,fy(delay.^2),'-b')

title(sprintf('tempX=%.2e K,tempY=%.2e K',fx.p1*consts.mrb/consts.kb,fy.p1*consts.mrb/consts.kb))

tempx=fx.p1*consts.mrb/consts.kb;
tempy=fy.p1*consts.mrb/consts.kb;

customsave(mfilename)

end

