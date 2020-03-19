function sortedStamps=sortTimeStampsByChannels(rawData,channels)
    if nargin==1
        channels=[1,2,3];
    end
    sortedStamps=cell(length(channels),1);
    %each row has the time stamps per channel
    for ind=1:length(channels)
        timeStamps=rawData(1,:);
        sortedStamps{ind}=timeStamps(channels(ind)==rawData(2,:));
    end
    