function bgimg = TakeBgImg(channelTable,camera)
%This function takes a background image
seq = LoadMotSeq(channelTable);
seq = [seq,{AnalogPulse(channelTable.PhysicalName{'CircCoil'},10,0,0),...
    AnalogPulse(channelTable.PhysicalName{'COOLVVAN'},10,0,CoolingPower2AO(880)),...
    Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},10,1)}];
seqUpload(seq);
pause(0.2);
bgimg=camera.snapshot;
pause(0.2);
seqUpload({Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},10,1)});
end

