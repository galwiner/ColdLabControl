function sectiondData = devidePhotPerCycleIntoParts(chN_phot_cycles,chN_phot_gc,edgeVec)
sectiondData{1,1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<edgeVec(1));
sectiondData{1,2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<edgeVec(1));

for ii = 2:length(edgeVec)
    
sectiondData{ii,1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<=edgeVec(ii)&chN_phot_gc{1}(:,2)>edgeVec(ii-1));
sectiondData{ii,2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<=edgeVec(ii)&chN_phot_gc{2}(:,2)>edgeVec(ii-1));

end
end