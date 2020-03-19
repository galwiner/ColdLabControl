function seq=TiSaphTuneSeq(channelTable,startTime,voltage)
seq={AnalogPulse(channelTable.PhysicalName{'TISAPH_PZT'},startTime,0,voltage),...
    Pulse(channelTable.PhysicalName{'ScopeTrigger'},startTime,20)};
end
