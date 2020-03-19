function setAHHCurrent(channelTable,coilName,current)
%sets the current in amperes in either the circular or rectangualr AHH PSUs
current=10*current/220;
if strcmpi(coilName,'circ')
    seqUpload(AOSetVoltageSeq(channelTable,'CircCoil',current));
elseif strcmpi(coilName,'rect')
    seqUpload(AOSetVoltageSeq(channelTable,'RectCoil',current));
else
    error('coilName must be circ or rect');
end

end
