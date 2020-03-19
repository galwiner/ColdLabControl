clear all
initp
p.gateNum = 500;
p.NAverage = 100;
simulate_data;
minTimeInGate = 0.025; %in us;
timeBetweenCycles = 0.1e6;%in us;
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,0.1e6,minTimeInGate);
p.g2PhotPerCycle=5000;
p.superGate=200;

p.g2Params.isplotSupGate = 1;
p.plotByString='gate';
process_WIS_v1

%% 

close(figure(12))
figure(12);
subplot(2,3,1);
plot(chN_phot_time{1}(:,1))
hold on
plot(chN_phot_time{2}(:,1))
title('time from first gate of cycle');
subplot(2,3,2);
plot(chN_phot_time{1}(:,2))
hold on
plot(chN_phot_time{2}(:,2))
title('time from preceding gate');

subplot(2,3,3);
plot(chN_phot_gc{1}(:,1))
hold on
plot(chN_phot_gc{2}(:,1))
title('gate position in run');

subplot(2,3,4);
plot(chN_phot_gc{1}(:,2))
hold on
plot(chN_phot_gc{2}(:,2))
title('gate position in cycle');

subplot(2,3,5);
plot(chN_phot_cycles{1}(:))
hold on
plot(chN_phot_cycles{2}(:))
title('cycle number');
