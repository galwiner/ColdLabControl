function freq = RydbergDet2synthHDFreq(det,n)
if nargin==1
n = 101;
end
%freq of resonance, known from EIT
switch n
    case 101
        resFreq = 395.2*2;
end
freq = det/2+resFreq;
end
