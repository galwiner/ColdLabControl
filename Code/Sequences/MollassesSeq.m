function seq = MollassesSeq(channelTable,startTime,current,MolassesDuration )
%Lee 12.09.17 
%This function returns a sequence that starts optical
%molasses. At the start time the magnetic field is turned off and after the
%duration the cooling and repump beams are turned off.
%All times are in us!
% seq = {AnalogPulse(channelTable.PhysicalName{'CircCoil'},startTime,0,0),... %Turn off current at startTime
%     AnalogPulse(channelTable.PhysicalName{'IGBT'},startTime+1/40,0,0),... %Turn off IGBT 1 clock sycle after startTime
%     Pulse(channelTable.PhysicalName{'cooling'},startTime+MolassesDuration,-1),... %Turn off cooling beam after the duration
%     Pulse(channelTable.PhysicalName{'repump'},startTime+MolassesDuration+1/40,-1)... %Turn off repump beam the duration + 1 clock cycle
%     };



seq = {
    AnalogPulse(channelTable.PhysicalName{'COOLVVAN'},startTime,0,CoolingPower2AO(800)),... %set full cooling power
    Pulse(channelTable.PhysicalName{'IGBT'},startTime,0),... %Turn on IGBT 
    AnalogPulse(channelTable.PhysicalName{'CircCoil'},startTime,current,0),... %Turn on circular AHH coils
    Pulse(channelTable.PhysicalName{'cooling'},startTime,0),... %Turn off cooling beam after the duration
    Pulse(channelTable.PhysicalName{'repump'},startTime,0)... %Turn off repump beam the duration + 1 clock cycle
    Pulse(channelTable.PhysicalName{'IGBT'},startTime+200e3,0),... %Turn off IGBT
    AnalogPulse(channelTable.PhysicalName{'CircCoil'},startTime+200e3,0,0),... %Turn off circular AHH coils
    Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},startTime+200e3,1),...%
    AnalogPulse(channelTable.PhysicalName{'COOLVVAN'},startTime+200e3,0,CoolingPower2AO(400)),...
    
    Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},startTime+200e3,1),...
    AnalogPulse(channelTable.PhysicalName{'IGBT'},startTime,1,0),... %Turn off IGBT 1 clock sycle after startTime
    AnalogPulse(channelTable.PhysicalName{'CircCoil'},startTime,0,0),... %Turn off current at startTime
    AnalogPulse(channelTable.PhysicalName{'IGBT'},startTime+1/40,0,0),... %Turn off IGBT 1 clock sycle after startTime
    Pulse(channelTable.PhysicalName{'cooling'},startTime+MolassesDuration,-1),... %Turn off cooling beam after the duration
    Pulse(channelTable.PhysicalName{'repump'},startTime+MolassesDuration+1/40,-1)... %Turn off repump beam the duration + 1 clock cycle
    };

% seq = {Pulse(channelTable.PhysicalName{'cooling'},startTime,-1),... %Turn off cooling beam after the duration
%     Pulse(channelTable.PhysicalName{'repump'},startTime,-1)... %Turn off repump beam the duration + 1 clock cycle
%     AnalogPulse(channelTable.PhysicalName{'CircCoil'},startTime+10,0,0),... %Turn off current at startTime
%     AnalogPulse(channelTable.PhysicalName{'IGBT'},startTime+10,0,0),... %Turn off IGBT 1 clock sycle after startTime
%     Pulse(channelTable.PhysicalName{'cooling'},startTime+200,0),... %Turn off cooling beam after the duration
%     Pulse(channelTable.PhysicalName{'repump'},startTime+200,0)... %Turn off repump beam the duration + 1 clock cycle
%     Pulse(channelTable.PhysicalName{'cooling'},startTime+MolassesDuration,-1),... %Turn off cooling beam after the duration
%     Pulse(channelTable.PhysicalName{'repump'},startTime+MolassesDuration+1/40,-1)... %Turn off repump beam the duration + 1 clock cycle
%     };

% seq = {AnalogPulse(channelTable.PhysicalName{'CircCoil'},startTime,0,0),... %Turn off current at startTime
%     Pulse(channelTable.PhysicalName{'cooling'},startTime+MolassesDuration,-1),... %Turn off cooling beam after the duration
%     Pulse(channelTable.PhysicalName{'repump'},startTime+MolassesDuration+1/40,-1)... %Turn off repump beam the duration + 1 clock cycle
%     };
end

