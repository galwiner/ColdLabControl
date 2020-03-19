%LD 07.12.17
%THis script loads a mot, then unloads it, and flashes the probe. After a
%time. the camera fleshes and we see where the mot went.

clear all
basicImports;
pixCam=pixelfly();
pixCam.src.E1ExposureTime_unit='us';
pixCam.src.E2ExposureTime=200;
pixCam.src.B1BinningHorizontal='04';
pixCam.src.B2BinningVertical='04';

delays = [200,400,1000,1500l];
 seqUpload(LoadMotSeq(channelTable,0,220))
 pause(2)
 Nimages=length(delays);
 pixCam.setHardwareTrig(Nimages);
 pixCam.start;
 for ind = 1:Nimages
    seqUpload({Pulse(channelTable.PhysicalName{'cooling'},0,-1),...%Turn off cooling
    Pulse(channelTable.PhysicalName{'ProbeSwitch'},100,20),... %Flash probe
    Pulse(channelTable.PhysicalName{'cooling'},delays(ind)+100,0),...%Turn on cooling
    Pulse(channelTable.PhysicalName{'pixelfly'},delays(ind)-5.6+100,20)...
    });
pause(1);
 end
images=pixCam.getImages(Nimages);
pixCam.stop;

figure;
 for ind = 1:Nimages
    subplot(2,2,ind)
    imagesc(images(:,:,ind));
    title(['Delay time ' num2str(delays(ind)) ' [\mus]']);
 end
    