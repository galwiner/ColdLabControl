%scan the cooling and repump frequencies and plot collected atom number
clear all
imaqreset
basicImports;
cooling=ICELaser('COM4',3,3,4);
repump=ICELaser('COM4',4,1,2);
pixCam=pixelfly();
pixCam.src.E1ExposureTime_unit='us';
pixCam.src.E2ExposureTime=1000;
pixCam.src.B1BinningHorizontal='04';
pixCam.src.B2BinningVertical='04';
seqUpload(UnloadMotSeq(channelTable));
bgimg=pixCam.snapshot;
x=pixCam.x;
y=pixCam.y;
seqUpload(LoadMotSeq(channelTable,0,70));
pause(3);
maxGamma=5;
% [imx,imy]=pixCam.getImSize;
% images=zeros(imx,imy,5);

coolingMult=cooling.getMultiplyer;
assert(coolingMult==8);

repumpMult=repump.getMultiplyer;
assert(repumpMult==64);

coolingloopsteps=10;
repumploopsteps=5;

Nimges=coolingloopsteps*repumploopsteps;

coolingfreqs=linspace(-7,1,coolingloopsteps)*consts.Gamma;
repumpfreqs=linspace(-3,3,repumploopsteps)*consts.Gamma;

for ind=1:coolingloopsteps
    for jnd=1:repumploopsteps
        cooling.setIntFreq(coolingDetToFreq(coolingfreqs(ind),coolingMult));
        disp(['Cooling set to ' num2str(coolingDetToFreq(coolingfreqs(ind),coolingMult))]);
        pause(2);
        repump.setIntFreq(repumpDetToFreq(repumpfreqs(jnd),repumpMult));
        disp(['Repump set to ' num2str(repumpDetToFreq(repumpfreqs(jnd),repumpMult))]);
        pause(2);
        idx=sub2ind([coolingloopsteps,repumploopsteps],ind,jnd);
        disp(['saving image ' num2str(idx)])
        images(:,:,idx)=fliplr(pixCam.snapshot-bgimg)';
    end
end

[I,J]=ind2sub([coolingloopsteps,repumploopsteps],1:Nimges);

figure
for ind=1:Nimges
    subplot(coolingloopsteps,repumploopsteps,ind);
    imagesc(images(:,:,ind));
    
    %     fit gaussians to these images. calibrate atom counting for the X4
    %     binning and then think about what you want to do again
end
figure
p=zeros(8,Nimges);
imsize=size(images(:,:,1));
fitimages=zeros(imsize(1),imsize(2),Nimges);
for ind=1:Nimges
    subplot(coolingloopsteps,repumploopsteps,ind);
    images(:,:,ind)
    [p(:,ind),fitimages(:,:,ind)]=fitImageGaussian2D([],[],images(:,:,ind));
    
    imagesc(fitimages(:,:,ind));
    
    
    %     fit gaussians to these images. calibrate atom counting for the X4
    %     binning and then think about what you want to do again
end


maxima=zeros(coolingloopsteps,repumploopsteps);
for i=1:Nimges
    if(p(7,i)==NaN)
        maxima(I(i),J(i))=0;    
    else 
        maxima(I(i),J(i))=p(7,i);
    end
end
figure;
imagesc(coolingfreqs,repumpfreqs,maxima);
colorbar
xlabel('Cooling f[\Gamma]')
ylabel('Repump f[\Gamma]')
title('Integrated cloud intensity. I_{dis}=4A, I_{Circ}=70A')
set(gcf,'color','white')
customsave();

%
% figure;
%
% plot(freqs,p(7,:),'o-');
% xlabel('Cooling f [\Gamma]');
% ylabel('integrated intensity');
% title('MOT loading scan, I_{dis}=4A, I_{circ}=70A')
% set(gcf,'color','white')
% customsave()

% for ind=1:loopsteps
%     for jnd=1:loopsteps
%         cooling.setIntFreq(coolingDetToFreq(freqs(ind),coolingMult));
%         repump.setIntFreq(repumpDetToFreq(freqs(jnd),repumpMult));
%         loopsteps * (ind-1) + jnd
%         pause(2);
%         images(:,:,loopsteps * (ind-1) + jnd)=fliplr(pixCam.snapshot)';
%     end
% end
%
% freqs=linspace(-10,10,20);
% for i=1:20
%     cooling.setIntFreq(coolingDetToFreq(freqs(i),8));
%     pause(1)
%     cooling.getIntFreq
%     images(:,:,i)=pixCam.snapshot;
% end
% figure;
% for i=1:20
%     subplot(4,5,i)
%     imagesc(images(:,:,i))
% end
%
% figure;
% for i=1:20
%     subplot(4,5,i)
%     [p,fitimages(:,:,i)]=fitImageGaussian2D([],[],double(images(:,:,i)),3);
%     subplot(4,5,i)
%     imagesc(fitimages(:,:,i))
%     maxima(i)=p(7);
%     if p(7)<0
%         error('error')
%     end
% end
%
% figure;
% plot(maxima)
%
%
