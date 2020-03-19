clear all
tic
basicImports;

exposureTime = 200;
pixCam=pixelfly();
pixCam.src.E2ExposureTime=exposureTime;
%pixCam.handle.Timeout = 1000;
cooling=ICELaser('COM4',3,3,4);
N=20;
flashpowers = linspace(20,880,N);

% seqUpload(LoadMotSeq(channelTable,0,70));
% setAHHCurrent(channelTable,'circ',0);
% seqUpload({AnalogPulse(channelTable.PhysicalName{'COOLVVAN'},0,0,CoolingPower2AO(flashpower))});
% pause(0.2);
% bgimg=pixCam.snapshot;
motLoadTime = 2e6;
tStart = 0;
delay = 1e3;
circCurrent = 70;
intrinsicDelay = 5.6;

Navrg = 5;
seqUpload(LoadMotSeq(channelTable,0,70))
seqUpload({AnalogPulse(channelTable.PhysicalName{'COOLVVAN'},0,0,CoolingPower2AO(880))});
pause(3)
%%
pixCam.setHardwareTrig(N*Navrg);

    pixCam.start;
 flushdata(pixCam.handle)
 
 for inda =1:Navrg
     for ind=1:N
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
            AnalogPulse(channelTable.PhysicalName{'COOLVVAN'},tStart+motLoadTime+delay-300,0,CoolingPower2AO(flashpowers(ind))),...
            Pulse(channelTable.PhysicalName{'pixelfly'},tStart+motLoadTime+delay-intrinsicDelay,20),...
            Pulse(channelTable.PhysicalName{'cooling'},tStart+motLoadTime+delay,0),...
            Pulse(channelTable.PhysicalName{'repump'},tStart+motLoadTime+delay,0),...
            Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},tStart+motLoadTime+delay+exposureTime+100,1),...
            AnalogPulse(channelTable.PhysicalName{'COOLVVAN'},tStart+motLoadTime+delay+exposureTime+100,0,CoolingPower2AO(880))...
            };
        tend = tStart+motLoadTime+delay+exposureTime+100;
        seqUpload(seq);
        pause(tend*(1e-6)+1);
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

