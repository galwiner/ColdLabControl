function [freq,startInds,endInds] = getDDSTriangleRampFreqVec(timeVec,ddsOvr,span,center)
%get the freq. vector for a triangle scan. i.e. scan in rising freq and
%then symmetrically in falling freq. 
inds = find(ddsOvr==0);
startInds(1) = 2*inds(1);
jumpInds = find(diff(inds)~=1,1);
startInds(2) = 2*inds(jumpInds+1);
endInds(1) = 2*inds(jumpInds);
endInds(2) = 2*inds(end);
% startInds = 2*(find(diff(ddsOvr)==-1));%the factor of two is because of the undersampling in the digital channels
% endInds = 2*(find(diff(ddsOvr)==1));%the factor of two is because of the undersampling in the digital channels
indSpan = min(endInds-startInds);
endInds = startInds+indSpan;
tStart = timeVec(startInds(1));
tEnd = timeVec(endInds(1));
timeVec = timeVec(startInds(1):endInds(1));
f1 = center-span/2;
f2 = center+span/2;
m = (f2-f1)/(tEnd-tStart);
c = f2-m*tEnd;
freq = m*timeVec+c;
end