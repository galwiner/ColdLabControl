function [freq,startInd,endInd] = getDDSDownRampFreqVec(timeVec,ddsCtl,ddsOvr,span,center)
digOr = ~or(ddsCtl,ddsOvr);
startInd = 2*(find(digOr,1,'first'));%the factor of two is because of the undersampling in the digital channels
endInd = 2*(find(digOr,1,'last'));
tStart = timeVec(startInd);
tEnd = timeVec(endInd);
timeVec = timeVec(startInd:endInd);
f1 = center+span/2;
f2 = center-span/2;
m = (f2-f1)/(tEnd-tStart);
c = f2-m*tEnd;
freq = m*timeVec+c;
end