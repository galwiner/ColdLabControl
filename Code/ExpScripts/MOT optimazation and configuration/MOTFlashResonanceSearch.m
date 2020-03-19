clear all
tic
basicImports;

exposureTime = 20;
pixCam=pixelfly();
pixCam.src.E2ExposureTime=exposureTime;
%pixCam.handle.Timeout = 1000;
cooling=ICELaser('COM4',3,3,4);
flashpower = 40;
seqUpload(LoadMotSeq(channelTable,0,70));
setAHHCurrent(channelTable,'circ',0);
seqUpload({AnalogPulse(channelTable.PhysicalName{'COOLVVAN'},0,0,CoolingPower2AO(flashpower))});
pause(0.2);
bgimg=pixCam.snapshot;
motLoadTime = 2e6;
tStart = 0;
delay = 1e3;
circCurrent = 70;
intrinsicDelay = 5.6;

N=20;
if mod(N,5)~= 0
    error('This code works only when mod(N,5)==0')
end
Navrg = 10;
detList = linspace(-5,5,N)*consts.Gamma;
freqList = coolingDetToFreq(detList,8);
seqUpload(LoadMotSeq(channelTable,0,70))
seqUpload({AnalogPulse(channelTable.PhysicalName{'COOLVVAN'},0,0,CoolingPower2AO(880))});
pause(3)
%%
pixCam.setHardwareTrig(N*Navrg);

    pixCam.start;
 flushdata(pixCam.handle)
 for inda = 1:Navrg
    for ind = 1:N
        cooling.sendSerialCommand(['EvtData 2 1 ' num2str(freqList(ind))]);
        cooling.sendSerialCommand('Save');
        freq=cooling.sendSerialCommand('EvtData? 2 1');
        
%         
        pause(0.5)
        seq = {...
            ...%Load MOT
            Pulse(channelTable.PhysicalName{'IGBT_circ'},tStart,0),...
            AnalogPulse(channelTable.PhysicalName{'CircCoil'},tStart,0,circCurrent*10/220),...
            Pulse(channelTable.PhysicalName{'cooling'},tStart,0)...
            Pulse(channelTable.PhysicalName{'repump'},tStart,0),...
            ...%Unload MOT
            Pulse(channelTable.PhysicalName{'cooling'},tStart+motLoadTime-200,-1),...
            Pulse(channelTable.PhysicalName{'repump'},tStart+motLoadTime-200,-1),...
            Pulse(channelTable.PhysicalName{'ScopeTrigger'},tStart+motLoadTime-10,10),...
            Pulse(channelTable.PhysicalName{'IGBT_circ'},tStart+motLoadTime,-1),...
            AnalogPulse(channelTable.PhysicalName{'CircCoil'},tStart+motLoadTime,0,0),...
            ...%Jump freq, set power to 50mw amd flash picture, and jump back, and set power to 880
            Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},tStart+motLoadTime+delay-300,1),...
            AnalogPulse(channelTable.PhysicalName{'COOLVVAN'},tStart+motLoadTime+delay-300,0,CoolingPower2AO(flashpower)),...
            Pulse(channelTable.PhysicalName{'pixelfly'},tStart+motLoadTime+delay-intrinsicDelay,20),...
            Pulse(channelTable.PhysicalName{'cooling'},tStart+motLoadTime+delay,0),...
            Pulse(channelTable.PhysicalName{'repump'},tStart+motLoadTime+delay,0),...
            Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},tStart+motLoadTime+delay+exposureTime+100,1),...
            AnalogPulse(channelTable.PhysicalName{'COOLVVAN'},tStart+motLoadTime+delay+exposureTime+100,0,CoolingPower2AO(880))...
            };
        tend = tStart+motLoadTime+delay+exposureTime+100;
        seqUpload(seq);
        pause(tend*(1e-6)+1);


%         if mod(N,5)~=0 && ind==N
%             images(:,:,(ind-mod(N,5)+1):ind,inda)=pixCam.getImages(mod(N,5));
%         end
    end
end
images(:,:,:)=pixCam.getImages(N*Navrg);
pixCam.stop;
%%
pause(3)
%fit images
% [fp,gof,fimages]=vec2DgaussFit([],[],images,bgimg,[],[]);
customsave(mfilename)
toc
%%
%imageViewer([],[],images(:,:,:,1),[],'Images1');
%imageViewer([],[],images(:,:,:,2),[],'Images2');
%imageViewer([],[],images(:,:,1:20),[],'Avrerage Images');
% imageViewer([],[],fimages,[],'Fits');
%
% figure;
% plot(detList/consts.Gamma,fp(7,:),'-o');








