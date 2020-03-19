function supCent = getSuperGateCenterFromSectionList(sectionsList)
supCent = movmean(sectionsList{1},2);
supCent(1) = [];
end
