clear all
tic
basicImports;

pixCam=pixelfly();

cooling=ICELaser('COM4',3,3,4);
N=5;
expTimes = linspace(3000,10000,N);

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
pixCam.setHardwareTrig(Navrg);

for ind =1:N
    pixCam.src.E2ExposureTime = expTimes(ind);
    pixCam.start;
    flushdata(pixCam.handle)
    for inda=1:Navrg
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
            ...%Jump freq, flash picture, and jump back, and set power to 880
            Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},tStart+motLoadTime+delay-300,1),...
            Pulse(channelTable.PhysicalName{'pixelfly'},tStart+motLoadTime+delay-intrinsicDelay,20),...
            Pulse(channelTable.PhysicalName{'cooling'},tStart+motLoadTime+delay,0),...
            Pulse(channelTable.PhysicalName{'repump'},tStart+motLoadTime+delay,0),...
            Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},tStart+motLoadTime+delay+expTimes(ind)+100,1),...
            };
        tend = tStart+motLoadTime+delay+expTimes(ind)+100;
        seqUpload(seq);
        pause(tend*(1e-6)+1);
    end
    images(:,:,ind,:)=pixCam.getImages(Navrg);
    pixCam.stop;
    pause(0.2)
end
%%
customsave(mfilename)
toc