
load('D:\Box Sync\Lab\ExpCold\Measurements\2019\05\16\tt\tt_160519_14__g2 measurement, no atoms.mat');

% load('D:\Box\Lab\ExpCold\Measurements\2019\05\16\tt\tt_160519_14__g2 measurement, no atoms.mat');

sortedPulses=sortTimeStampsByChannels(datMat);
sortedPulses=removeEarlyPhotonsRawData(sortedPulses);

loadTime=1e12;


cycles=300;
extendedCycles=extendCycles(sortedPulses,loadTime,cycles);
runs=cycles;
% [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell(extendedCycles,20,20000);

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(extendedCycles,20000);
% chN_phot_time{1}=chN_phot_time{1}*1e-6;
% chN_phot_time{2}=chN_phot_time{2}*1e-6;
% plot(chN_phot_time{1}(:,1))
% plot(chN_phot_gc{1}(:,2))
% % plot(chN_phot_cycles{1})
% 
% % close(figure(1))
% figure(1);
% hold off
% yyaxis left
% plot(chN_phot_gc{1}(:,2))
% yyaxis right
% plot(chN_phot_cycles{1},'r')
runs=300
save('extenedCycleData.mat','chN_phot_cycles','chN_phot_gc','chN_phot_time','phot_per_cycle','chN_gates_each_cycle');

filename='extenedCycleData.mat';

process_WIS_v1
