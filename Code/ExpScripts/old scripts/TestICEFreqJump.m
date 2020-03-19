%20.12.17 LD
%THe purpace of the script is to test how long it tacks the ICE to jump in to resonance.

clear all
basicImports;
pixCam=pixelfly();
pixCam.src.E1ExposureTime_unit='us';
pixCam.src.E2ExposureTime=100;
pixCam.src.B1BinningHorizontal='04';
pixCam.src.B2BinningVertical='04';

motLoadTime = 2e6; %in us;
seqUpload(LoadMotSeq(channelTable,0,70))
pause(motLoadTime*1e-6);
TOFtime = 3000;

triggerList = [TOFtime-100,TOFtime-150,TOFtime-200,TOFtime-250,TOFtime-300,TOFtime-350];
N = length(triggerList);
pixCam.setHardwareTrig(N);
pixCam.start;
%Set up sequence
for ind = 1:N
seqUpload(LoadMotSeq(channelTable,0,70))
pause(motLoadTime*1e-6);
seq={Pulse(channelTable.PhysicalName{'cooling'},0,-1)...
    Pulse(channelTable.PhysicalName{'repump'},0,-1),...
    Pulse(channelTable.PhysicalName{'IGBT_circ'},10,-1),...
    AnalogPulse(channelTable.PhysicalName{'CircCoil'},10,0,0),...
    Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},triggerList(ind),1),...
    Pulse(channelTable.PhysicalName{'pixelfly'},TOFtime-5.6,20),...
    Pulse(channelTable.PhysicalName{'cooling'},TOFtime,0)...
    Pulse(channelTable.PhysicalName{'repump'},TOFtime,0),...
    Pulse(channelTable.PhysicalName{'ICEEVTTRIG'}...
    ,TOFtime+pixCam.src.E2ExposureTime,1)...
    };
    
seqUpload(seq);
pause(0.1);
end

% for ind = 1:N
% seqUpload(LoadMotSeq(channelTable,0,70))
% pause(motLoadTime*1e-6);
% seq={Pulse(channelTable.PhysicalName{'cooling'},0,-1)...
%     Pulse(channelTable.PhysicalName{'repump'},0,-1),...
%     Pulse(channelTable.PhysicalName{'IGBT_circ'},10,-1),...
%     AnalogPulse(channelTable.PhysicalName{'CircCoil'},10,0,0),...
%     Pulse(channelTable.PhysicalName{'pixelfly'},TOFtime-5.6,20),...
%     Pulse(channelTable.PhysicalName{'cooling'},TOFtime,0)...
%     Pulse(channelTable.PhysicalName{'repump'},TOFtime,0)...
%  
%     };
%     
% seqUpload(seq);
% pause(0.1);
% end

images=pixCam.getImages(N);
titles = {};
for ind = 1:N
    titles{ind} = ['Jump time, before imaging, is ' num2str(TOFtime-triggerList(ind)) ' [\mus]'];
end
imageViewer([],[],images,titles);

pixCam.stop;
customsave(mfilename)



