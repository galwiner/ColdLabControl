% clear all
% load('D:\Box Sync\Lab\ExpCold\Measurements\2019\04\23\230419_30.mat');
% parsedData=parseDetectorData(r.rawTTData);
% r.parsedPulseData = parsedData;
% figure;
% subplot(2,1,1)
% stem(r.parsedPulseData{1},r.parsedPulseData{1},'b')
% hold on
% stem(r.parsedPulseData{3},4*r.parsedPulseData{3},'--r','LineWidth',1)
% ylim([0 1])
% subplot(2,1,2)
% stem(r.parsedPulseData{2},r.parsedPulseData{2},'b')
% hold on
% stem(r.parsedPulseData{3},4*r.parsedPulseData{3},'--r','LineWidth',1)
% ylim([0 1])

s=parseDetectorData(r.rawTTData)
figure;
subplot(2,1,1)
histogram(flattenGateArray(s{1}),100)
subplot(2,1,2)
histogram(flattenGateArray(s{2}),100)
