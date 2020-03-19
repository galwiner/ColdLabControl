% thermometry without touching detuning of any beam, CW MOT

clear all
imaqreset
basicImports;
pixCam=pixelfly();
pixCam.src.E1ExposureTime_unit='us';
pixCam.src.E2ExposureTime=200;
pixCam.src.B1BinningHorizontal='04';
pixCam.src.B2BinningVertical='04';

% take a bg image with light on but magnetic field off
seqUpload(LoadMotSeq(channelTable));
setAHHCurrent(channelTable,'circ',0);
pause(2);
bgimg=pixCam.snapshot;
x=pixCam.x;
y=pixCam.y;

params.Icirc=70;
params.coolingPower='107mw'; %per beam
params.repumpPower='32mW';
params.coolingDet='-5'; %Gamma
params.repumpDet='0'; %Gamma
params.exposureTime=pixCam.src.E2ExposureTime;
params.Idisp='4A';
sizeIm=size(bgimg);
params.BiasY = -46; %mA
params.BiasZ = 50; %mA
params.BiasX = -30; %mA
params.WP1= 60;
params.WP2= 138;
% params.delayList=[20,5000]; %times for the TOF flights in microseconds
params.delayList=[200,1000,3000,5000,10000]; %times for the TOF flights in microseconds

NTOFimages=length(params.delayList); %how many images are we taking?

pixCam.setHardwareTrig(NTOFimages);

% images=zeros(sizeIm(1),sizeIm(2),NTOFimages); %prealocate image array

             
delay=params.delayList; %in microseconds
motLoadTime=4e6; %2 seconds
pixCam.start;
for ind=1:NTOFimages
    fprintf('taking image: %d at delay %d \n',ind,delay(ind));
    seqUpload(TOFseq(channelTable,'pixelfly',delay(ind),motLoadTime,pixCam.src.E2ExposureTime,params.Icirc));
    pause(motLoadTime*1e-6*1.3);
end

setAHHCurrent(channelTable,'circ',0);
images=pixCam.getImages(NTOFimages);
pixCam.stop;

scale=1.65e-5*4; %m/pixel. New ratio as of 11.12.17. The *4 factor is for binning.
imsize=size(images(:,:,1));
x=linspace(-imsize(1)/2,imsize(1)/2,imsize(1))*scale;
y=linspace(-imsize(2)/2,imsize(2)/2,imsize(2))*scale;
%%
figure
for ind=1:NTOFimages
    numCol=4;
    numRow=ceil(NTOFimages/numCol);
    subplot(numRow,numCol,ind);
    imagesc(x,y,images(:,:,ind)-bgimg);
    xlabel('x [m]');
    ylabel('y [m]');
    axis square
    title(sprintf('delay = %.1e [\\mu S]',delay(ind)));
end

%%
figure
% fitImages=zeros(size(images));

cleanimages=imcleaner(images,bgimg,ones(4));
for ind=1:NTOFimages
    numCol=4;
    numRow=ceil(NTOFimages/numCol);
    subplot(numRow,numCol,ind);
    [fitparams(:,ind),~,fitImages(:,:,ind)]=fitImageGaussian2D(x,y,cleanimages(:,:,ind));
    imagesc(x,y,fitImages(:,:,ind));
    axis square
    xlabel('x [m]');
    ylabel('y [m]');
    title(sprintf('t=%d [uS],sx=%.2 m',delay(ind),fitparams(5,ind)))
end

%% extracting temperature



figure;
hold on

% T=consts.mrb*(0.2450)^2/consts.kb
delay=delay*1e-6;
fx=fit(delay'.^2,fitparams(5,:)'.^2,'poly1');
fy=fit(delay'.^2,fitparams(6,:)'.^2,'poly1');

plot(delay.^2,fitparams(5,:).^2,'or')
plot(delay.^2,fx(delay.^2),'-r')

plot(delay.^2,fitparams(6,:).^2,'ob')
plot(delay.^2,fy(delay.^2),'-b')

title(sprintf('tempX=%.2e uK,tempY=%.2e uK',1e6*fx.p1*consts.mrb/consts.kb,1e6*fy.p1*consts.mrb/consts.kb))

%% extract acceleration due to gravity g
delayS=params.delayList*1e-6;
figure;
hold on
plot(delayS,-fitparams(3,:),'ob');
[f,gof]=fit(delayS',fitparams(3,:)','poly2');
cf=confint(f);
gc=cf(:,1);
deltag=2*(gc(2)-gc(1));
plot(delayS,-f(delayS),'-r');
fprintf('%.2e*t^2+%.2e*t+%.2e',f.p1,f.p2,f.p3);
xlabel('t[s]');
ylabel('z [m]');
title(sprintf('TOF experiment, z position (free fall) g=%.2e(%.2e)',2*f.p1,deltag)); 
% p0 = [p(3,1),10];
% fit_func = @(t,a) a(1)+0.5*a(2)*t.^2;
% f1 = fminsearch(@(a) sum(fit_func(delayS,a)- p(3,:)), p0, optimset('Display', 'on', 'MaxIter', 100));

% plot(delayS,fit_func(delayS,f1),'-');
% xlabel('t[s]');
% ylabel('z[m]');
% conf=confint(f1,0.95);
% title(sprintf('accleration due to gravity: %.2f +/- %.2f m/s^2',2*f1.p1,abs(2*conf(1,1)-2*f1.p1)))


%%
customsave(mfilename)

