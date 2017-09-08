function seq=UnloadMotSeq(channelTable,startTime)
%%Gal W
%this function generates the sequence needed to UNLOAD a mot at startTime.
%channelTable is from ControlSystem/configuration
%if it is the only passed param, startTime defaults to 0 



if nargin==1
    startTime=0;
end

seq={AnalogPulse(channelTable.PhysicalName{'IGBT'},startTime,0,0),...
    AnalogPulse(channelTable.PhysicalName{'CircCoil'},startTime,0,0),...
    Pulse(channelTable.PhysicalName{'repump'},startTime,-1),...
    Pulse(channelTable.PhysicalName{'cooling'},startTime,-1)...
    };

end