instrreset
% make object
sc=keysightScope('USB0::0x0957::0x1796::MY55140790::0::INSTR');
% set the trigger to channel 0, 0V level, positive edge (also possible:
% NEG, EITHER
sc.setTrigger(1,0,'POS');
% set screen voltage range to 1mV
sc.setVrange(1,1e-3);
% set screen time range to 1mS
sc.setTimebase(1e-3);
% make a plot of channel 4
sc.plotChan(4);
% make a plot of all channels
sc.plotScreen;
%collect data from all channels
dat=sc.getChannels;
%collect data from channel 1
[x,y]=sc.getChan(1)
%turn on channel 1,2,3
sc.setChan(1,1)
sc.setChan(2,1)
sc.setChan(3,1)
%set state to run, single or stop
sc.setState('run')
sc.setState('single')
sc.setState('stop')
% the object cleanly closes the connection when it is done (e.g when you do
% clear all or at any other time it disappears. 
clear sc
