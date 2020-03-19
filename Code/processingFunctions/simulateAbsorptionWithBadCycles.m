for jj = 1:300
clear all
global p
initp
OD = 1;
span = 30;
Ncycles = 50;
det = linspace(-span/2,span/2,Ncycles);
trans = exp(-OD*(p.consts.Gamma/2)^2./((p.consts.Gamma/2)^2+det.^2));
GatesPerCycle = 1000;
gateTime = 20;
CycleTime = 1e6;
loadtime = 5e5;
sortedPulses{1} = [];
sortedPulses{2} = [];
sortedPulses{3} = [];
totPhot = 0;

%% generate referance, without missing or double cycles
missedCycles = [];
doubledCycles = [];
for ii = 1:Ncycles
    if any(ii==missedCycles)
        continue
    end
    disterbInGate = [];
    tmpGates = (0:GatesPerCycle-1)*gateTime+(ii-1)*CycleTime;
    photNum = round(trans(ii)*GatesPerCycle);
    totPhot = totPhot+photNum;
    disterbInGate(1,:) = 1:photNum;
    disterbInGate(2,:) = 1:photNum;
    sortedPulses{1} = [sortedPulses{1},tmpGates];
    sortedPulses{2} = [sortedPulses{2},tmpGates(disterbInGate(1,:))+1];
    sortedPulses{3} = [sortedPulses{3},tmpGates(disterbInGate(2,:))+1];
    if any(ii==doubledCycles)
        tmpGates = (0:GatesPerCycle-1)*gateTime+(ii-1)*CycleTime+loadtime;
        photNum = round(trans(ii)*GatesPerCycle);
        totPhot = totPhot+photNum;
        disterbInGate(1,:) = 1:photNum;
        disterbInGate(2,:) = 1:photNum;
        sortedPulses{1} = [sortedPulses{1},tmpGates];
        sortedPulses{2} = [sortedPulses{2},tmpGates(disterbInGate(1,:))+1];
        sortedPulses{3} = [sortedPulses{3},tmpGates(disterbInGate(2,:))+1];
    end
end
sortedPulses{1} = sortedPulses{1}*1e6;
sortedPulses{2} = sortedPulses{2}*1e6;
sortedPulses{3} = sortedPulses{3}*1e6;
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle_ref,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,0.1e6,0.025);
%%
totPhot = 0;
sortedPulses{1} = [];
sortedPulses{2} = [];
sortedPulses{3} = [];
missedCycles = randperm(Ncycles,5);
doubledCycles = randperm(Ncycles,5);
while any(ismember(doubledCycles,missedCycles))
    doubledCycles = randperm(Ncycles,5);
end
for ii = 1:Ncycles
    if any(ii==missedCycles)
        continue
    end
    disterbInGate = [];
    tmpGates = (0:GatesPerCycle-1)*gateTime+(ii-1)*CycleTime;
    photNum = round(trans(ii)*GatesPerCycle);
    totPhot = totPhot+photNum;
    disterbInGate(1,:) = 1:photNum;
    disterbInGate(2,:) = 1:photNum;
    sortedPulses{1} = [sortedPulses{1},tmpGates];
    sortedPulses{2} = [sortedPulses{2},tmpGates(disterbInGate(1,:))+1];
    sortedPulses{3} = [sortedPulses{3},tmpGates(disterbInGate(2,:))+1];
    if any(ii==doubledCycles)
        tmpGates = (0:GatesPerCycle-1)*gateTime+(ii-1)*CycleTime+loadtime;
        photNum = round(trans(ii)*GatesPerCycle);
        totPhot = totPhot+photNum;
        disterbInGate(1,:) = 1:photNum;
        disterbInGate(2,:) = 1:photNum;
        sortedPulses{1} = [sortedPulses{1},tmpGates];
        sortedPulses{2} = [sortedPulses{2},tmpGates(disterbInGate(1,:))+1];
        sortedPulses{3} = [sortedPulses{3},tmpGates(disterbInGate(2,:))+1];
    end
end
sortedPulses{1} = sortedPulses{1}*1e6;
sortedPulses{2} = sortedPulses{2}*1e6;
sortedPulses{3} = sortedPulses{3}*1e6;
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,0.1e6,0.025);
phot_per_cycle_bad = phot_per_cycle;
p.ttStartTime = 0;
p.cycleTimesReltv = (0:Ncycles-1)*CycleTime*1e-6;
p.TTGateStartTimes = 0*p.cycleTimesReltv;
fixCycles
assert(all(sort(doubledCycles)==doubleCycles),'Double Cycle Detection failed')
assert(all(sort(missedCycles)==missingCycles),'missing cycle Detection failed')
% figure;
% plot(phot_per_cycle_ref)
% hold on
% plot(phot_per_cycle_bad)
% plot(phot_per_cycle,'o')
% xlabel('cycle #')
% ylabel('phot__per__cycle')
% legend('ref, no missing or double cycles','without fix','with fix','Location','southeast')
% title(sprintf('cycles fix test with %d missing cycles and %d double cycles',length(missedCycles),length(doubledCycles)))
% set(gca,'fontsize',14)
% set(gcf,'WindowState','maximized')
assert(all(find(isnan(phot_per_cycle))==sort(missedCycles)),'missing cycle correction failed')
nonMissedCycles = 1:Ncycles;
nonMissedCycles(missedCycles) = [];
assert(all(phot_per_cycle(~isnan(phot_per_cycle))==phot_per_cycle_ref(nonMissedCycles)),'Double or missing cycle correction failed')
end