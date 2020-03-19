function sectionedRes = sectionTTRes(chN_phot_cycles,chN_phot_gc)
global p
if ~isfield(p,'supergateNum')
    p.supergateNum=25;
end %supregateNum is the number of sectios
idxList=[];
delta=floor(p.gateNum/p.supergateNum);
if p.supergateNum==1
idxList=[1,delta];
else
for ind=1:p.supergateNum-1
idxList(ind,:)=[1+(ind-1)*delta,delta*ind];
end
idxList(end+1,:)=[1+(ind)*delta,p.gateNum];
end
PhotPerCycle={};
for ind=1:p.supergateNum
gmax=idxList(ind,2);
gmin=idxList(ind,1);
local_chN_phot_cycles{1,ind}=chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<=gmax & chN_phot_gc{1}(:,2)>=gmin);
local_chN_phot_cycles{2,ind}=chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<=gmax&chN_phot_gc{2}(:,2)>=gmin);
if isempty(local_chN_phot_cycles{1,ind})||isempty(local_chN_phot_cycles{2,ind})
    PhotPerCycle{end+1} = nan;
    continue
end
PhotPerCycle{end+1}=removeBadCyclesandMean({local_chN_phot_cycles{:,ind}},p.NAverage);
end
sectionedRes = PhotPerCycle;
end