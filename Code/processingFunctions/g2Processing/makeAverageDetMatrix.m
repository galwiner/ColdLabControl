function mat=makeAverageDetMatrix(detectorStamps,binNum)
%     this is the denominator
    pulseNum=length(detectorStamps);
    det1=detectorStamps{1};
    det2=detectorStamps{2};
    mat=(histcounts([det1{:}],binNum)/pulseNum)'*(histcounts([det2{:}],binNum)/pulseNum);
end
