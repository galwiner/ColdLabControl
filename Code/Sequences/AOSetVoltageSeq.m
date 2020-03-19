function seq=AOSetVoltageSeq(channelTable,chanName,voltage)

if ~exist('channelTable','var')
    basicImports
end
if voltage > 10 || voltage < -10
    error('max output voltage: 10V');
end
seq={AnalogPulse(channelTable.PhysicalName{chanName},0,0,voltage)};
end
