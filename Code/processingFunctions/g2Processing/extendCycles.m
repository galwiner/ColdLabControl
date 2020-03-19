function extendedPulses=extendCycles(sortedPulses,loadTime,nCycles)
%function to take data from a single cycle and extend it to additional
%cycles

gateDiff=max(sortedPulses{1})-min(sortedPulses{1});
chan1Diff=max(sortedPulses{2})-min(sortedPulses{2});
chan2Diff=max(sortedPulses{3})-min(sortedPulses{3});
gates=sortedPulses{1};
chan1=sortedPulses{2};
chan2=sortedPulses{3};

for ind=1:nCycles-1
% gates=[gates gateDiff+sortedPulses{1}+ind*loadTime];
% chan1=[chan1 chan1Diff+sortedPulses{2}+ind*loadTime];
% chan2=[chan2 chan2Diff+sortedPulses{3}+ind*loadTime];
gates=[gates sortedPulses{1}+ind*loadTime];
chan1=[chan1 sortedPulses{2}+ind*loadTime];
chan2=[chan2 sortedPulses{3}+ind*loadTime];

end
extendedPulses={gates,chan1,chan2};
end

