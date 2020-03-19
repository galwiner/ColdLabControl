%test real multicycle data
tic
load('D:\Box Sync\Lab\ExpCold\Measurements\2019\05\20\tt\tt_200519_12__g2 measurement, no atoms.mat');

sortedPulses=sortTimeStampsByChannels(datMat);
sortedPulses=removeEarlyPhotonsRawData(sortedPulses);

loadTime=1e12;

[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,20000);

save('D:\Box Sync\Lab\ExpCold\Measurements\2019\05\20\tt\multiCycleData.mat','chN_phot_cycles','chN_phot_gc','chN_phot_time','phot_per_cycle','chN_gates_each_cycle');

filename='D:\Box Sync\Lab\ExpCold\Measurements\2019\05\20\tt\multiCycleData.mat';
runs=495;
process_WIS_v1
toc