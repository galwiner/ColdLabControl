clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.hasTTresults=1;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr

%%
p.NAverage = 1;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','TTGate','duration',10,'value','high'});
p.s.addBlock({'startTTraw','Buffer_size',1e3,'chan1',1,'chan2',2,'measTime',1e6,'max_time',1e5,'min_time',10,'bin_size',1e3});
p.s.run();
clicks=r.corrRes(2,:);
clicks(clicks<0)=0;
timeTags=r.corrRes(1,:); %in pS
figure;
stem(timeTags,clicks)