function seq=LoadMotSeq(channelTable,startTime,setCurrent)
%Gal W
%this function generates the sequence needed to load a mot at startTime.
%channelTable is from ControlSystem/configuration
%if it is the only passed param, startTime defaults to 0 
%setCurrent sets the circular coil current to 100 A by default.
if nargin==1
    startTime=0;
    setCurrent = 100;
end

if nargin==2
    setCurrent = 100;
end

setCurrent = setCurrent * 10/220; %converting amps to volts for the analog channel
seq={AnalogPulse(channelTable.PhysicalName{'IGBT'},startTime,0,5),...
    AnalogPulse(channelTable.PhysicalName{'CircCoil'},startTime,0,setCurrent),...
    Pulse(channelTable.PhysicalName{'repump'},startTime,0),...
    Pulse(channelTable.PhysicalName{'cooling'},startTime,0)...
    };

end