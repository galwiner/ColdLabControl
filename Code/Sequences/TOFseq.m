function seq=TOFseq(channelTable,cameraName,delay,motLoadTime,exposureTime)
%Gal W 080917
%sequence to collect images from the camera connected to trig channel
%delay is the time MOT relase and image in microseconds. 
%default delay =100uS, default mot load time 1 s
%MOT is unloaded 100 mS after the second image is taken
%


if nargin==1
    cameraName='pixelfly';
    delay=1;
    motLoadTime=2e6; 
end

if nargin==2
    delay=1;
    motLoadTime=2e6; 
end


if nargin==3
    motLoadTime=2e6; 
end
if strcmp(cameraName,'pixelfly')
    intrinsicDelay=5.6; %microseconds (see manual)
    
end

% exposure=500;

    seq=[LoadMotSeq(channelTable),...
         UnloadMotSeq(channelTable,motLoadTime),...
         {Pulse(channelTable.PhysicalName{'cooling'},motLoadTime+delay,exposureTime),Pulse(channelTable.PhysicalName{'repump'},motLoadTime+delay,exposureTime)},...
        trigImage(channelTable,motLoadTime+delay-intrinsicDelay,cameraName) 
        ]; %trigger the image before the intended trigger time to compensate for intrinsic delay

%     seq={AnalogPulse(channelTable.PhysicalName{'IGBT'},0,0,5),...
%     AnalogPulse(channelTable.PhysicalName{'CircCoil'},0,0,100*10/220),...
%     Pulse(channelTable.PhysicalName{'repump'},0,0),...
%     Pulse(channelTable.PhysicalName{'cooling'},0,0)...
%     AnalogPulse(channelTable.PhysicalName{'IGBT'},motLoadTime,0,0),...
%     AnalogPulse(channelTable.PhysicalName{'CircCoil'},motLoadTime,0,0),...
%     Pulse(channelTable.PhysicalName{'repump'},motLoadTime,-1),...
%     Pulse(channelTable.PhysicalName{'cooling'},motLoadTime,-1),...
%     Pulse(channelTable.PhysicalName{cameraName},motLoadTime+delay-intrinsicDelay,20),...
%     Pulse(channelTable.PhysicalName{'cooling'},motLoadTime+delay,0),...
%     Pulse(channelTable.PhysicalName{'repump'},motLoadTime+delay,0)
%     }; %trigger the image before the intended trigger time to compensate for intrinsic delay



end
