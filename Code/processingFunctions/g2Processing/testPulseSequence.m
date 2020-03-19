function testPulseSequence(sortedDat,originalDat)
    Osum=0;
    for ind=1:length(sortedDat)
        for jnd=1:length(sortedDat{ind})
            Osum=Osum+length(sortedDat{ind}{jnd});
        end
    end
    
    originalSum=0;
    for ind=1:length(originalDat)-1
        originalSum=originalSum+length(originalDat{ind});
    end
    
    fprintf("sorted pulse sum of time stamps is: %d. original sum of time pulses is %d\n",Osum,originalSum)
    assert(originalSum==Osum)
    
    flattenedTimes=[];
    for ind=length(sortedDat)
        for jnd=1:length(sortedDat{ind})
            for knd=1:length(sortedDat{ind}{jnd})
            flattenedTimes(end+1)=sortedDat{ind}{jnd}(knd);
            end
        end
    end
    fprintf("max time is %.4f ms\n",1e-9*max(flattenedTimes))
    histogram(flattenedTimes)
end
