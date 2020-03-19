%checking the click rate.
%checking the after pulsing rate to determine what role it plays in the
%ttRateApp measured pulse rate. 
ChannelToggler('SPCMShutter',1);
ChannelToggler('ProbeSwitch',1)
ttstr=TTTimeTagStream(tt,1000,[2,3]);
dat=ttstr.getData();
tags=[double(dat.getTimestamps);double(dat.getChannels)];
cns=sortTimeStampsByChannels(tags);
diffs1=diff(cns{2});
diffs2=diff(cns{3});

figure;
subplot(1,2,1)
histogram(diffs1(diffs1<100e6),40)
xlabel('time[ps]')
title('SPCM1')
set(gca,'FontSize',14)
subplot(1,2,2)
histogram(diffs2(diffs2<100e6),40)
xlabel('time[ps]')
title('SPCM2')
set(gca,'FontSize',14)
dim = [.2 .5 .3 .3];
str = 'total time tags: 1000 in BOTH detectors combined';
annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize',14);

ChannelToggler('SPCMShutter',0);

ChannelToggler('ProbeSwitch',0);

