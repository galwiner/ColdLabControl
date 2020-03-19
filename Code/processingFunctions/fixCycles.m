%% this script uses the cycle times and tt start time to find missing and souble cycles (caused by FPGA not running or running twice respectvly)
global p
global r
diffData = diff(double(r.ttRes.sortedPulses{1}));
newCycleInds = find(diffData>1e10)+1;
newCycleInds = [1,newCycleInds];
newCycleTimes = round(double(r.ttRes.sortedPulses{1}(newCycleInds))*1e-12*1e3)*1e-3;
p.ttStartTimeSecs = round(double(p.ttStartTime)*1e-12*1e3)*1e-3;
newCycleTimesRltv = newCycleTimes-p.ttStartTimeSecs;
% p.TTGateStartTimes = 0.5*ones(size(p.cycleTimesReltv));
missingCycles = [];
doubleCycles = [];
% figure;
% if length(newCycleTimesRltv)<length(p.cycleTimesReltv)
% plot(p.cycleTimesReltv(1:length(newCycleTimesRltv))+p.TTGateStartTimes(1:length(newCycleTimesRltv))-newCycleTimesRltv,'o')
% else
%     plot(p.cycleTimesReltv+p.TTGateStartTimes-newCycleTimesRltv(1:length(p.cycleTimesReltv)),'o')
% end
ii = 1;
while ii<=length(p.cycleTimesReltv)
    if ii==length(p.cycleTimesReltv)&&length(p.cycleTimesReltv)>length(newCycleTimesRltv)||ii>length(newCycleTimesRltv)
        missingCycles(end+1) = ii;
        newCycleTimesRltv(end+1) = newCycleTimesRltv(end);
        newCycleTimesRltv(ii+1:end)= newCycleTimesRltv(ii:end-1);
        newCycleTimesRltv(ii) = p.cycleTimesReltv(ii)+p.TTGateStartTimes(ii);
        ii = ii+1;
        continue
    end
    if ii>length(newCycleTimesRltv)
        missingCycles(end+1) = ii+1;
        newCycleTimesRltv(end+1) = newCycleTimesRltv(end);
        newCycleTimesRltv(ii+1:end)= newCycleTimesRltv(ii:end-1);
        newCycleTimesRltv(ii) = p.cycleTimesReltv(ii)+p.TTGateStartTimes(ii);
        ii = ii+1;
        continue
    end
    if abs((p.cycleTimesReltv(ii)+p.TTGateStartTimes(ii)-newCycleTimesRltv(ii)))>0.35
        if any(abs((p.cycleTimesReltv(ii+1:end)+p.TTGateStartTimes(ii+1:end)-newCycleTimesRltv(ii)))<0.35)
        missingCycles(end+1) = ii;
        newCycleTimesRltv(end+1) = newCycleTimesRltv(end);
        newCycleTimesRltv(ii+1:end)= newCycleTimesRltv(ii:end-1);
        newCycleTimesRltv(ii) = p.cycleTimesReltv(ii)+p.TTGateStartTimes(ii);
        elseif abs((p.cycleTimesReltv(ii-1)+p.TTGateStartTimes(ii-1)-newCycleTimesRltv(ii)))>0.35
        doubleCycles(end+1) = ii-1;
        newCycleTimesRltv(ii) = [];
        continue
        end
    end
    ii = ii+1;
end
if length(newCycleTimesRltv)>length(p.cycleTimesReltv)
    for ii = 1:length(newCycleTimesRltv)-length(p.cycleTimesReltv)
        doubleCycles(end+1) = ii-1+length(p.cycleTimesReltv);
        newCycleTimesRltv(ii) = [];
    end
end
% figure;
% plot(p.cycleTimesReltv(1:length(newCycleTimesRltv))+p.TTGateStartTimes(1:length(newCycleTimesRltv))-newCycleTimesRltv,'o')
% fixMissingCycle;
for ii = 1:length(p.cycleTimesReltv)
    if any(ii==missingCycles)
        phot_per_cycle(end+1) = nan;
        phot_per_cycle = [phot_per_cycle(1:ii-1),nan,phot_per_cycle(ii:(end-1))];
        chN_phot_cycles{1}(chN_phot_cycles{1}>=ii) = chN_phot_cycles{1}(chN_phot_cycles{1}>=ii,:)+1;%add 1 to all next cycles
        chN_phot_cycles{2}(chN_phot_cycles{2}>=ii) = chN_phot_cycles{2}(chN_phot_cycles{2}>=ii,:)+1;%add 1 to all next cycles
        chN_gates_each_cycle{1}((end+1)) = nan;
        chN_gates_each_cycle{2}(end+1) = nan;
    end
    if any(ii==doubleCycles)
        if ii==50
            ii;
        end
        phot_per_cycle(ii) = [];
        for mm = 1:2
            chN_phot_gc{mm}(chN_phot_cycles{mm}==ii,:) = [];
            chN_phot_time{mm}(chN_phot_cycles{mm}==ii,:) = [];
            chN_gates_each_cycle{mm}(ii) = [];
        end
        chN_phot_cycles{1}(chN_phot_cycles{1}==ii) = [];%remove the bad cycle
        chN_phot_cycles{2}(chN_phot_cycles{2}==ii) = [];%remove the bad cycle
        chN_phot_cycles{1}(chN_phot_cycles{1}>ii) = chN_phot_cycles{1}(chN_phot_cycles{1}>ii,:)-1;%reduce all next cycles by 1
        chN_phot_cycles{2}(chN_phot_cycles{2}>ii) = chN_phot_cycles{2}(chN_phot_cycles{2}>ii,:)-1;%reduce all next cycles by 1
    end
end
