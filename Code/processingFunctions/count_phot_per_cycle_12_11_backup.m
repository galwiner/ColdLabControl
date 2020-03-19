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
binEdges = (minCycle-0.5):NAverage:(maxCycle+0.5);
if isempty(chN_phot_cycles{1})
    phot_per_cycle = 0;
    return
end
phot_per_cycle = histcounts(chN_phot_cycles{1},binEdges)/NAverage;
phot_per_cycle = phot_per_cycle + histcounts(chN_phot_cycles{2},binEdges)/NAverage;
end
