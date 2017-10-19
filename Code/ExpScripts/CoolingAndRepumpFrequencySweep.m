%scan the cooling and repump frequencies and plot collected atom number
cooling=ICELaser('COM4',3,3,4);
repump=ICELaser('COM4',4,1,2);
pixCam=pixelfly();
maxGamma=1;
[imx,imy]=pixCam.getImSize;
images=zeros(imx,imy,5);

coolingMult=cooling.getMultiplyer;
repumpMult=repump.getMultiplyer;
loopsteps=3;
freqs=linspace(-maxGamma,maxGamma,loopsteps);
% for ind=1:loopsteps
%     for jnd=1:loopsteps
%         cooling.setIntFreq(coolingDetToFreq(freqs(ind),coolingMult));
%         repump.setIntFreq(repumpDetToFreq(freqs(jnd),repumpMult));
%         loopsteps * (ind-1) + jnd
%         pause(2);
%         images(:,:,loopsteps * (ind-1) + jnd)=fliplr(pixCam.snapshot)';
%     end
% end
freqs=linspace(-10,10,20);
for i=1:20
    cooling.setIntFreq(coolingDetToFreq(freqs(i),8));
    pause(1)
    cooling.getIntFreq
    images(:,:,i)=pixCam.snapshot;
end
figure;
for i=1:20
    subplot(4,5,i)
    imagesc(images(:,:,i))
end

figure;
for i=1:20
    subplot(4,5,i)
    [p,fitimages(:,:,i)]=fitImageGaussian2D([],[],double(images(:,:,i)),3);
    subplot(4,5,i)
    imagesc(fitimages(:,:,i))
    maxima(i)=p(7);
    if p(7)<0
        error('error')
    end
end

figure;
plot(maxima)


