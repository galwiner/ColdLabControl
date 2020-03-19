length(r.corrRes)
length(r.sortedTimeStamps{2})


load('sorted_local.mat') %chan 1, chan2 and chan3. chan3 is the begining time of each pulse
%make the data structure referenced to pulse start time
pulses=shiftTimeStampsToPulseStart(dat);
testPulseSequence(pulses,dat);
[N1,edges1]=histcounts([pulses{1}{:}],100);
[N2,edges2]=histcounts([pulses{2}{:}],100);
figure;

bar(edges1(2:end),N1)
hold on
bar(edges2(2:end),N2)





