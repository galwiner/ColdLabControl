% script for scanning cooling det and mag field gradient

%scan the cooling frequencies and circular coil current and plot collected atom number
clear all
imaqreset
basicImports;
cooling=ICELaser('COM4',3,3,4);
pixCam=pixelfly();
pixCam.src.E1ExposureTime_unit='us';
pixCam.src.E2ExposureTime=2500;
pixCam.src.B1BinningHorizontal='04';
pixCam.src.B2BinningVertical='04';
seqUpload(UnloadMotSeq(channelTable));
bgimg=pixCam.snapshot;
x=pixCam.x;
y=pixCam.y;
seqUpload(LoadMotSeq(channelTable,0,70));
pause(3);
maxGamma=5;
params.coolingPower='40mW';
params.exposureTime='2.5ms'
% [imx,imy]=pixCam.getImSize;
% images=zeros(imx,imy,5);

coolingMult=cooling.getMultiplyer;
assert(coolingMult==8);

coolingloopsteps=10;
currentSteps=10;

Nimges=coolingloopsteps*currentSteps;

coolingfreqs=linspace(-13,1,coolingloopsteps)*consts.Gamma;
currentVals=linspace(20,220,currentSteps);

for ind=1:coolingloopsteps
    for jnd=1:currentSteps
        cooling.setIntFreq(coolingDetToFreq(coolingfreqs(ind),coolingMult));
        disp(['Cooling set to ' num2str(coolingDetToFreq(coolingfreqs(ind),coolingMult))]);
        setAHHCurrent(channelTable,'circ',currentVals(jnd))
        disp(['Current set to: ' num2str(currentVals(jnd))]);
        pause(2);
        idx=sub2ind([coolingloopsteps,currentSteps],ind,jnd);
        disp(['saving image ' num2str(idx)])
        images(:,:,idx)=fliplr(pixCam.snapshot-bgimg)';
    end
end

[I,J]=ind2sub([coolingloopsteps,currentSteps],1:Nimges);

figure
for ind=1:Nimges
    subplot(coolingloopsteps,currentSteps,ind);
    imagesc(images(:,:,ind));
    
    %     fit gaussians to these images. calibrate atom counting for the X4
    %     binning and then think about what you want to do again
end
figure
p=zeros(8,Nimges);
imsize=size(images(:,:,1));
fitimages=zeros(imsize(1),imsize(2),Nimges);
% for ind=1:Nimges
%     subplot(coolingloopsteps,currentSteps,ind);
%     
%     [p(:,ind),fitimages(:,:,ind)]=fitImageGaussian2D([],[],images(:,:,ind));
%     
%     imagesc(fitimages(:,:,ind));
%     
%     
%     %     fit gaussians to these images. calibrate atom counting for the X4
%     %     binning and then think about what you want to do again
% end


maxima=zeros(coolingloopsteps,currentSteps);
for i=1:Nimges
    if isnan(p(7,i))
        maxima(I(i),J(i))=0;    
    else 
        maxima(I(i),J(i))=p(7,i);
    end
end
figure;
imagesc(coolingfreqs,currentVals,maxima);
colorbar
xlabel('Cooling f[\Gamma]')
ylabel('current I[A]')
title('Integrated cloud intensity. I_{dis}=4A')
set(gcf,'color','white')
customsave();

