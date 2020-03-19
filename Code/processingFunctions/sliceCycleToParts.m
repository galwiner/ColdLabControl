function slices=sliceCycleToParts(chN_phot_cycles,chN_phot_gc,phot_per_cycle,sliceEndGateList,loopNumsList)
%loopNumsList= [,,NAverage]
maxCycle=loopNumsList(1)*loopNumsList(2)*loopNumsList(3);
NAverage=loopNumsList(3);
InnerNum=loopNumsList(1);
OuterNum=loopNumsList(2);


chN_phot_gc{1}(chN_phot_cycles{1}>maxCycle,:) = [];
chN_phot_gc{2}(chN_phot_cycles{2}>maxCycle,:) = [];

chN_phot_cycles{1}(chN_phot_cycles{1}>maxCycle) = [];
chN_phot_cycles{2}(chN_phot_cycles{2}>maxCycle) = [];
slices=cell(1,length(sliceEndGateList));

for ind=1:length(sliceEndGateList)
    if ind>1
        slice_ChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<sliceEndGateList(ind)&chN_phot_gc{1}(:,2)>sliceEndGateList(ind-1));
        slice_ChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<sliceEndGateList(ind)&chN_phot_gc{2}(:,2)>sliceEndGateList(ind-1));
        slice_ChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)<sliceEndGateList(ind)&chN_phot_gc{1}(:,2)>sliceEndGateList(ind-1),:);
        slice_ChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)<sliceEndGateList(ind)&chN_phot_gc{2}(:,2)>sliceEndGateList(ind-1),:);
    else
        slice_ChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<sliceEndGateList(ind));
        slice_ChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<sliceEndGateList(ind));
        slice_ChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)<sliceEndGateList(ind),:);
        slice_ChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)<sliceEndGateList(ind),:);
    end
photPerCycle=removeBadCyclesandMean(slice_ChN_phot_cycles,NAverage);
if length(photPerCycle)<InnerNum*OuterNum
    photPerCycle(end+1:InnerNum*OuterNum) = nan;
end
slices{ind}=reshape(photPerCycle,InnerNum,OuterNum);
end
slice_ChN_phot_cycles{1} = chN_phot_cycles{1}(chN_phot_gc{1}(:,2)>sliceEndGateList(end));
slice_ChN_phot_cycles{2} = chN_phot_cycles{2}(chN_phot_gc{2}(:,2)>sliceEndGateList(end));
slice_ChN_phot_gc{1} = chN_phot_gc{1}(chN_phot_gc{1}(:,2)>sliceEndGateList(end),:)-sliceEndGateList(end);
slice_ChN_phot_gc{2} = chN_phot_gc{2}(chN_phot_gc{2}(:,2)>sliceEndGateList(end),:)-sliceEndGateList(end);
slices{end+1}=removeBadCyclesandMean(slice_ChN_phot_cycles,NAverage);
% if any(~isfinite(slices{end}))
%     error('this');
% end

if length(slices{end})<InnerNum*OuterNum
    slices{end}(end+1:InnerNum*OuterNum) = nan;
end

slices{end}=reshape(slices{end},InnerNum,OuterNum);


end
