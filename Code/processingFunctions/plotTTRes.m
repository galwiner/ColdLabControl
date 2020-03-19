% plotTTRes
if ~exist('chN_phot_cycles')||~exist('chN_phot_gc')||~exist('chN_phot_time')||~exist('phot_per_cycle')||~exist('chN_gates_each_cycle')
   error('can''t run plotTTRes without makeChenCell2 results in the workspace')
end
global p
% PhotPerCycle=removeBadCyclesandMean(chN_phot_cycles,p.NAverage);
figure;
%plot number of photons per cycle
subplot(2,2,1)
plot(1:max(max(chN_phot_cycles{1}),max(chN_phot_cycles{2})),phot_per_cycle);
% plot(1:max(max(chN_phot_cycles{1}),max(chN_phot_cycles{2})),PhotPerCycle);
xlabel('cycle #')
ylabel('photon count');
title('phot per cycle');



%plot photons per gate
subplot(2,2,[3,4])
binNum  = max(max(chN_gates_each_cycle{1}),max(chN_gates_each_cycle{2}));
[N1,eg] = histcounts(chN_phot_gc{1}(:,2),binNum);
plot(1:binNum,N1);
hold on
[N2,eg] = histcounts(chN_phot_gc{2}(:,2),binNum);
plot(1:binNum,N2);
legend('chan 1','chan 2');
subplot(2,2,2)
[N1,eg] = histcounts(chN_phot_time{1}(:,2),100);
cents =movmean(eg,2);
cents(1) = [];
plot(cents,N1);
[N2,eg] = histcounts(chN_phot_time{2}(:,2),100);
hold on
plot(cents,N2);
legend('chan 1','chan 2');