% Sequence to demonstrate programming frequency jump events in ICE OPLS

% sets listener on address 7 (111, ICEADDR0 is LSB)

seqUpload(channelToggleSeq(channelTable,'ICEADDR0',1));
seqUpload(channelToggleSeq(channelTable,'ICEADDR1',1));
seqUpload(channelToggleSeq(channelTable,'ICEADDR2',1));

% trigger a jump event at t=0
seqUpload({Pulse(channelTable.PhysicalName{'ICEEVTTRIG'},500,1)})