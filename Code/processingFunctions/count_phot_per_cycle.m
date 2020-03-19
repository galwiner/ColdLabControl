function phot_per_cycle= count_phot_per_cycle(chN_phot_cycles,varargin)
%varargin{1} = Naverage
% varargin{2} = minCycle
% varargin{3} = maxCycle
if ~isempty(varargin)
    NAverage = varargin{1};
    if length(varargin)>1
        minCycle = varargin{2};
        maxCycle = varargin{3};
    else
        maxCycle = max(max(chN_phot_cycles{1}),max(chN_phot_cycles{2}));
        minCycle = min(min(chN_phot_cycles{1}),min(chN_phot_cycles{2}));
    end
else
    NAverage = 1;
    maxCycle = max(max(chN_phot_cycles{1}),max(chN_phot_cycles{2}));
    minCycle = min(min(chN_phot_cycles{1}),min(chN_phot_cycles{2}));
end
if ~iscell(chN_phot_cycles)
    tmpchN_phot_cycles = chN_phot_cycles;
    clear chN_phot_cycles
    chN_phot_cycles{1} = tmpchN_phot_cycles;
    chN_phot_cycles{2} = nan;
end
% maxCycle = max(max(chN_phot_cycles{1}),max(chN_phot_cycles{2}));
% minCycle = min(min(chN_phot_cycles{1}),min(chN_phot_cycles{2}));
binEdges = (minCycle-0.5):1:(maxCycle+0.5);
cycleList = minCycle:1:maxCycle;
superCycleList = 1:length(cycleList)/NAverage;
if isempty(chN_phot_cycles{1})
    phot_per_cycle = 0;
    return
end
all_phot_per_cycle = histcounts(chN_phot_cycles{1},binEdges);
all_phot_per_cycle = all_phot_per_cycle + histcounts(chN_phot_cycles{2},binEdges);
phot_per_cycle = zeros(1,length(superCycleList));
if isempty(superCycleList) %this happens when NAverage>maxCycle.
    phot_per_cycle = mean(all_phot_per_cycle);
    return
end
for ii = 1:length(superCycleList)
    tmpList =  all_phot_per_cycle((ii-1)*NAverage+1:ii*NAverage);
    if ~all(tmpList==0)
        phot_per_cycle(ii) = sum(tmpList)/sum(tmpList~=0);
    else
        phot_per_cycle(ii) = 0;
    end
end    
end
