function processTTRes(datMat,cycleTime,threshholdTime,savePath)
global p
if ~exist('cycleTime')
    cycleTime = 2e6;
end
if ~exist('threshholdTime')
    threshholdTime = 0.5;
end
sortedPulses=sortTimeStampsByChannels(datMat);
fprintf('%d gates received\n',length(sortedPulses{1}))
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,cycleTime,threshholdTime);
%remove 
chN_phot_time{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum,:) = [];
chN_phot_time{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum,:) = [];
chN_phot_gc{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum,:) = [];
chN_phot_gc{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum,:) = [];
chN_phot_cycles{1}(chN_phot_cycles{1}>p.NAverage*p.freqNum) = [];
chN_phot_cycles{2}(chN_phot_cycles{2}>p.NAverage*p.freqNum) = [];