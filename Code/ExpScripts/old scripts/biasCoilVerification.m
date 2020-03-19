%Bias compensation verification


clear all
basicImports
pixCam=pixelfly()
thCam=Thorcam();
thCam.startLiveMode
pixCam.setExposure(20000);
pixCam.setBinning('04','04')
thCam.setExposure(100);

seqUpload(LoadMotSeq(channelTable))
setAHHCurrent(channelTable,'circ',0);
pixBg=pixCam.snapshot;
thBg=thCam.getImage;

%BiasPsu1=BiasPSU('TCPIP::10.10.10.106::inst0::INSTR'); %Y bias coils on Chan 1, Z Bias coil on Chan 2
%BiasPsu2=BiasPSU('TCPIP::10.10.10.107::inst0::INSTR'); %X Bias coil on Chan 2

params.biasX=-0.0107;
params.biasY=-0.046;
params.biasZ=0.03;

BiasPsu1.setCurrent(1,params.biasY);
BiasPsu1.setCurrent(2,params.biasZ);
BiasPsu2.setCurrent(2,params.biasX);


pause(3);
nsteps=15;
currentVals=linspace(30,220,nsteps);
sth=size(thBg);
spx=size(pixBg);
thImages=zeros(sth(1),sth(2),nsteps);
thFitIm=zeros(sth(1),sth(2),nsteps);
pixImages=zeros(spx(1),spx(2),nsteps);
pixFitIm=zeros(spx(1),spx(2),nsteps);
PixCamScale=4.32e-5; %m/pixel
ThCamScale=2.35e-5; %m/pixel;

PixCamX=linspace(-spx(1)/2,spx(1)/2,spx(1))*PixCamScale;
PixCamY=linspace(-spx(2)/2,spx(2)/2,spx(2))*PixCamScale;

ThCamX=linspace(-sth(1)/2,sth(1)/2,sth(1))*ThCamScale;
ThCamY=linspace(-sth(2)/2,sth(2)/2,sth(2))*ThCamScale;



for ind=1:nsteps
    setAHHCurrent(channelTable,'circ',currentVals(ind));
    pause(3);
    pixImages(:,:,ind)=pixCam.snapshot;
    [pp(:,ind),pixFitIm(:,:,ind)]=fitImageGaussian2D(PixCamX,PixCamY,pixImages(:,:,ind)-pixBg);
    thImages(:,:,ind)=thCam.getImage;
    [tp(:,ind),thFitIm(:,:,ind)]=fitImageGaussian2D(ThCamX,ThCamY,thImages(:,:,ind)-thBg);
    disp(['Loop #' num2str(ind) ' out of ' num2str(nsteps)])
    
end

maxDev(1)=max(pp(3,:)-mean(pp(3,:)));
maxDev(2)=max(pp(4,:)-mean(pp(4,:)));
maxDev(3)=max(tp(3,:)-mean(tp(3,:)));
maxDev(4)=max(tp(4,:)-mean(tp(4,:)));

figure
hold on
plot(currentVals,pp(3,:)-mean(pp(3,:)),'or-');
plot(currentVals,tp(3,:)-mean(tp(3,:)),'ob-');
plot(currentVals,pp(4,:)-mean(pp(4,:)),'ok-');
plot(currentVals,tp(4,:)-mean(tp(4,:)),'og-');
xlabel('circular coil current [A]');
ylabel('cloud center displacement [m]');
legend({'Pixelfly x','Thorcam x','Pixelfly y','Thorcam y'});

figure
hold on
plot(1./currentVals,pp(3,:)-mean(pp(3,:)),'or-');
plot(1./currentVals,tp(3,:)-mean(tp(3,:)),'ob-');
plot(1./currentVals,pp(4,:)-mean(pp(4,:)),'ok-');
plot(1./currentVals,tp(4,:)-mean(tp(4,:)),'og-');
xlabel('1/coil current current [A^{-1}]');
ylabel('cloud center displacement [m]');
legend({'Pixelfly x','Thorcam x','Pixelfly y','Thorcam y'});


fprintf(['Max deviation per axis is: \n pix cam x: %.2e [m] \n'...
    'pix cam y: %.2e[m]\n'...
    'th cam x: %.2e [m]\n'...
    'th cam y: %.2e [m]\n'],maxDev)

figure;
subplot(2,2,1)
imagesc(ThCamX,ThCamY,sum(thImages,3));
subplot(2,2,2)
imagesc(PixCamX,PixCamY,sum(pixImages,3));

subplot(2,2,3)
imagesc(ThCamX,ThCamY,sum(thFitIm,3));

subplot(2,2,4)
imagesc(PixCamX,PixCamY,sum(pixFitIm,3));

customsave(mfilename)

figure;
subplot(2,2,1)
filtImag1 = thImages(:,:,end-1)-thBg;
filtImag1(filtImag1<0)=0;
imagesc(filtImag1);
subplot(2,2,2)
filtImag2 = thImages(:,:,end)-thBg;
filtImag2(filtImag2<0)=0;
imagesc(filtImag2);

subplot(2,2,3)
imagesc(thFitIm(:,:,end-1));
subplot(2,2,4)
imagesc(thFitIm(:,:,end));

