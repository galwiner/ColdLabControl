function [freqs,startInds,endInds] = getDDSUpRampFreqVec(timeVec,ddsCtl,ddsOvr,span,center)
% get freq vec for a the rising part of a freq. ramp
digAnd = and(ddsCtl,~ddsOvr);
% startInd = 2*(find(digAnd,1));%the factor of two is because of the undersampling in the digital channels
startInds=2*find(diff(and(ddsCtl,~ddsOvr))==1);%the factor of two is because of the undersampling in the digital channels
endInds=2*find(diff(and(ddsCtl,~ddsOvr))==-1);
tStarts = timeVec(startInds);
tEnds = timeVec(endInds);
timeVecs={};
for ind=1:length(tStarts) 
    timeVecs{ind} = timeVec(startInds(ind):endInds(ind));
    f1 = center-span/2;
    f2 = center+span/2;
    m = (f2-f1)/(tEnds(ind)-tStarts(ind)); %slope
    c = f2-m*tEnds(ind); %intercept
    freqs{ind} = m*timeVecs{ind}+c;
end


end