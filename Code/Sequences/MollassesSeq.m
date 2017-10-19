function seq = MollassesSeq(channelTable,startTime,duration )
%Lee 12.09.17 
%This function returns a sequence that starts optical
%molasses. At the start time the magnetic field is turned off and after the
%duration the cooling and repump beams are turned off.
%All times are in us!
seq = {AnalogPulse(channelTable.PhysicalName{'CircCoil'},startTime,0,0),... %Turn off current at startTime
    AnalogPulse(channelTable.PhysicalName{'IGBT'},startTime+1/40,0,0),... %Turn off IGBT 1 clock sycle after startTime
    Pulse(channelTable.PhysicalName{'cooling'},startTime+duration,-1),... %Turn off cooling beam after the duration
    Pulse(channelTable.PhysicalName{'repump'},startTime+duration+1/40,-1)... %Turn off repump beam the duration + 1 clock cycle
    };
end

