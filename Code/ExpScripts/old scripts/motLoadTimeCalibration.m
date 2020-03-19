
clear all

% imaqreset
basicImports;
pixCam=pixelfly();
pixCam.src.E2ExposureTime=200;
params.coolingPower=400;
%cooling=ICELaser('COM4',3,3,4);
%cooling.setIntFreq(coolingDetToFreq(-5*consts.Gamma,8));
seqUpload(AOSetVoltageSeq(channelTable,'COOLVVAN',CoolingPower2AO(params.coolingPower)));
params.DispenserCurrent = '4A';
params.circCoilCurrent = '100A';
params.circRectCurrent = '0A';
N=2;
trigTimes=linspace(250,3000,N)*1e3;

% take a bg image with light on but magnetic field off
seqUpload(LoadMotSeq(channelTable));
setAHHCurrent(channelTable,'circ',0);
pause(1);
bgimg=pixCam.snapshot;
seqUpload(UnloadMotSeq(channelTable));
pause(1);
averaging = 1;
pixCam.setHardwareTrig(averaging*N);
seq=LoadMotSeq(channelTable,0,100);
for ind=1:length(trigTimes)
seq=[seq,{Pulse(channelTable.PhysicalName{'pixelfly'},trigTimes(ind),20)}];
end
pixCam.start;
for jnd = 1:averaging
seqUpload(seq)
pause(4);
tmpImages=pixCam.getImages(N);

for ind=1:N
    [pf(:,ind,jnd),gof(:,ind,jnd),fitImages(:,:,ind,jnd)]=fitImageGaussian2D([],[],tmpImages(:,:,ind)-bgimg);
    if isnan(pf(1,ind))==1
        pf(:,ind,:) =0;
        fitImages(:,:,ind,:)=0;
    end
end
seqUpload(UnloadMotSeq(channelTable));
pause(1);
images(:,:,:,jnd)=tmpImages;
disp(jnd)
end
%%
pixCam.stop;


figure;
hold on;
 averageInt = mean(squeeze(pf(7,:,:)),2);
 IntStd = std(squeeze(pf(7,:,:)),[],2);
%  errorbar(trigTimes,averageInt./max(averageInt),IntStd,'-bo');
%  errorbar(trigTimes,averageInt400,IntStd,'-ro');
plot(trigTimes,averageInt./max(averageInt),'ob-')
plot(trigTimes,averageInt400./max(averageInt400),'or-')
%plot(trigTimes,pf(7,:))
title(['Mot Load time - No pre molasses. Average over ' num2str(averaging) ' times']);
xlabel('Trigger time [\mus]');
ylabel('Normalized MOT brightness (pf(7)/max)');
legend({'700mW','400mW'});
 %imageViewer([],[],images,string(trigTimes*1e-3),'MOT load images')
 %imageViewer([],[],fitImages,string(trigTimes*1e-3),'MOT load fits')
 customsave(mfilename);

