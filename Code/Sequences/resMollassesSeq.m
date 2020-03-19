function seq = resMollassesSeq(channelTable,startTime,MolassesDuration)
%Lee & Gal 06.12.17 
%This function returns a sequence that starts optical
%molasses with cooling beam jumping to resonance before turning on.  At the start time the magnetic field is turned off and after the
%duration the cooling and repump beams are turned off.
%All times are in us!
% seq = {AnalogPulse(channelTable.PhysicalName{'CircCoil'},startTime,0,0),... %Turn off current at startTime
%     AnalogPulse(channelTable.PhysicalName{'IGBT'},startTime+1/40,0,0),... %Turn off IGBT 1 clock sycle after startTime
%     Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},startTime+1/40,1),...
%     Pulse(channelTable.PhysicalName{'cooling'},startTime+MolassesDuration,-1),... %Turn off cooling beam after the duration
%     Pulse(channelTable.PhysicalName{'repump'},startTime+MolassesDuration+1/40,-1),... %Turn off repump beam the duration + 1 clock cycle
%     Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},startTime+MolassesDuration+2/40,1)
%     };
seq = {Pulse(channelTable.PhysicalName{'cooling'},startTime,-1),... %Turn off cooling beam after the duration
    Pulse(channelTable.PhysicalName{'repump'},startTime,-1)... %Turn off repump beam the duration + 1 clock cycle
    AnalogPulse(channelTable.PhysicalName{'CircCoil'},startTime+10,0,0),... %Turn off current at startTime
    AnalogPulse(channelTable.PhysicalName{'IGBT'},startTime+10,0,0),... %Turn off IGBT 1 clock sycle after startTime
Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},startTime+10,1),...
    Pulse(channelTable.PhysicalName{'cooling'},startTime+200,0),... %Turn off cooling beam after the duration
    Pulse(channelTable.PhysicalName{'repump'},startTime+200,0)... %Turn off repump beam the duration + 1 clock cycle
    Pulse(channelTable.PhysicalName{'cooling'},startTime+MolassesDuration,-1),... %Turn off cooling beam after the duration
    Pulse(channelTable.PhysicalName{'repump'},startTime+MolassesDuration+1/40,-1),... %Turn off repump beam the duration + 1 clock cycle
    Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},startTime+MolassesDuration,1)};

% seq = {AnalogPulse(channelTable.PhysicalName{'CircCoil'},startTime,0,0),... %Turn off current at startTime
%     Pulse(channelTable.PhysicalName{'cooling'},startTime+MolassesDuration,-1),... %Turn off cooling beam after the duration
%     Pulse(channelTable.PhysicalName{'repump'},startTime+MolassesDuration+1/40,-1)... %Turn off repump beam the duration + 1 clock cycle
%     };
end

