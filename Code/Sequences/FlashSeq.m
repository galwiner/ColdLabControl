function seq = FlashSeq(channelTable,tStart,flashPower)
%This function returns a sequence for flashing, bedore taking an image. It
%assumes a loaded MOT
seq = {Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},tStart,1),... %Trigger freq jump
       AnalogPulse(channelTable.PhysicalName{'COOLVVAN'},tStart,0,CoolingPower2AO(flashPower))};%Set power to flashPower
end

