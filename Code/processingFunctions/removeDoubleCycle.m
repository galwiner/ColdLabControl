% diffData = diff(double(sortedPulses{1}));
% diffData = diffData(diffData>1e10);
% [N,edges] = histcounts(diffData);
% [~,peakDiffind] = max(N);
% badInds = find(diffData<0.9*edges(peakDiffind));
for kk = 1:length(badInds)
    phot_per_cycle(badInds(kk)) = [];
    for mm = 1:2
        chN_phot_gc{mm}(chN_phot_cycles{mm}==badInds(kk),:) = [];
        chN_phot_time{mm}(chN_phot_cycles{mm}==badInds(kk),:) = [];
        chN_gates_each_cycle{mm}(badInds(kk)) = [];
    end
    chN_phot_cycles{1}(chN_phot_cycles{1}==badInds(kk)) = [];%remove the bad cycle
    chN_phot_cycles{2}(chN_phot_cycles{2}==badInds(kk)) = [];%remove the bad cycle
    chN_phot_cycles{1}(chN_phot_cycles{1}>badInds(kk)) = chN_phot_cycles{1}(chN_phot_cycles{1}>badInds(kk),:)-1;%reduce all next cycles by 1
    chN_phot_cycles{2}(chN_phot_cycles{2}>badInds(kk)) = chN_phot_cycles{2}(chN_phot_cycles{2}>badInds(kk),:)-1;%reduce all next cycles by 1
end
