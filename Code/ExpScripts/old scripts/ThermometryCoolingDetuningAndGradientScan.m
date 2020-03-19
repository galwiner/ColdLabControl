% thermometry for different magnetic field gradients and different cooling
% detunings


clear all
imaqreset
basicImports;
cooling=ICELaser('COM4',3,3,4);
pixCam=pixelfly();
pixCam.src.E1ExposureTime_unit='us';
pixCam.src.E2ExposureTime=2500;
pixCam.src.B1BinningHorizontal='04';
pixCam.src.B2BinningVertical='04';
% take a bg image with light on but magnetic field off
seqUpload(LoadMotSeq(channelTable));
setAHHCurrent(channelTable,'circ',0);
pause(2);

bgimg=pixCam.snapshot;

x=pixCam.x;
y=pixCam.y;


% seqUpload(LoadMotSeq(channelTable,0,70));
% pause(3);
maxGamma=5;
params.coolingPower='40mW';
params.exposureTime=pixCam.src.E2ExposureTime;
params.maxGammaCooling=1;
params.minGammaCooling=-5;
params.minCircCurrent=50;
params.maxCircCurrent=150;
coolingMult=cooling.getMultiplyer;
assert(coolingMult==8);

coolingloopsteps=5;
currentSteps=5;


sizeIm=size(bgimg);



coolingfreqs=linspace(params.minGammaCooling,params.maxGammaCooling,coolingloopsteps)*consts.Gamma;
currentVals=linspace(params.minCircCurrent,params.maxCircCurrent,currentSteps);

params.delayList=[1,10,100,500,1000,1500];
TOFimages=length(params.delayList);
pixCam.setHardwareTrig(TOFimages)
images=zeros(sizeIm(1),sizeIm(2),coolingloopsteps,currentSteps,TOFimages);
Nimges=coolingloopsteps*currentSteps*TOFimages;

for ind=1:coolingloopsteps
    for jnd=1:currentSteps
        cooling.setIntFreq(coolingDetToFreq(coolingfreqs(ind),coolingMult));
        disp(['Cooling set to ' num2str(coolingDetToFreq(coolingfreqs(ind),coolingMult))]);
        setAHHCurrent(channelTable,'circ',currentVals(jnd))
        disp(['Current set to: ' num2str(currentVals(jnd))]);
        pause(2);
       
        pixCam.start
        for knd=1:TOFimages
             
            delay=params.delayList(knd); %in microseconds
            motLoadTime=2e6; %2 seconds
            seqUpload(TOFseq(channelTable,'pixelfly',1,motLoadTime,pixCam.src.E2ExposureTime))
        end
        
        images(:,:,ind,jnd,:)=pixCam.getImages(TOFimages);
        pixCam.stop
        fprintf('saving images %d:%d:_\n',ind,jnd);
%         images(:,:,idx)=fliplr(pixCam.snapshot-bgimg)';
    end
end

for k=1:TOFimages
    figure
    for i=1:coolingloopsteps
        for j=1:currentSteps
            subplot(coolingloopsteps,currentSteps,sub2ind([coolingloopsteps,currentSteps],i,j))
            imagesc(images(:,:,i,j,k)-bgimg);
        end
    end
end

customsave(mfilename)

