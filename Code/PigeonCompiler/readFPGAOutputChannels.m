function [analogChannels,digitalChannels]=readFPGAOutputChannels()
    global inst
    dat=inst.com.readMemoryBlock(1101,14);
    analogChannels=10*dat(1:8)/2^15; %analog outputs in volts
    d=de2bi(typecast(int16(dat(9:end)),'uint16'),16);
    
    digitalChannels(1,:)=[d(1,:),d(2,:)];
%     digitalChannels(1,:)=digitalChannels(1,1:16);
    digitalChannels(2,:)=[d(3,:),d(4,:)];
%     digitalChannels(2,:)=digitalChannels(2,1:21);
    digitalChannels(3,:)=[d(5,:),d(6,:)];
%     digitalChannels(3,:)=digitalChannels(3,1:21);
%     channelStates=dat;
end
