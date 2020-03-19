%measuring the dark counts of the time tagger

clear all
global p
global r
global inst
DEBUG=0;


initp

p.hasScopResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.hasTTresults=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
p.looping=1;

p.expName = 'time tagger dark count measurement';
%%
% inst.tt.reset()
inst.tt.setTriggerLevel(1,1)
inst.tt.setTriggerLevel(2,1)
inst.tt.setTriggerLevel(3,1)
%%
p.s=sqncr();
% p.s.addBlock({'st1artTTgatedCount','countVectorLen',1});
p.s.addBlock({'startTTraw','Buffer_size',1e6,'chan1',1,'chan2',2});
% p.s.addBlock({'startTTcorrelation','chan1',1,'chan2',2,'gate',3,'binwidth',3e4,'n_bins',100});
p.s.addBlock({'TrigScope'});

p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
p.s.addBlock({'pause','duration',3e3});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',1});
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'forStart'})
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',1e6});
p.s.addBlock({'pause','duration',2e6});
p.s.addBlock({'forEnd','value',10});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','low','duration',0});
p.s.addBlock({'GenPause','duration',20e6});
p.s.run();
% 
% figure;
% subplot(2,1,1)
% 
% plot(r.cnt(1,:),'-r')
% hold on
% plot(r.cnt(3,:),'-b')
% title('counts')
% subplot(2,1,2)
% plot(r.corrRes)
% title('correlations')

countDebug
% figure;
% 
% subplot(2,2,1)
% stem(r.sortedTimeStamps{1})
% subplot(2,2,2)
% stem(r.sortedTimeStamps{2})
% subplot(2,2,3:4)
% a=histcounts(r.sortedTimeStamps{1},100);
% b=histcounts(r.sortedTimeStamps{2},100);
% (b'*a);
% imagesc(b'*a);
% length(r.sortedTimeStamps{3})
% 
% 
