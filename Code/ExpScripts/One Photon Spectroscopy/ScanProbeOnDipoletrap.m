%cooling power sweep with fast mode spectroscopy
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.picsPerStep = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
initinst
initr
p.expName = 'Scan Probe on Dipole trap';
%%
% channelInd = find(strcmpi(seq{ii},'channel')); %DDS channel, 1-4
% channelVal = seq{ii}{channelInd+1};
% centerInd = find(strcmpi(seq{ii},'center')); %DDS Scan center
% centerVal = seq{ii}{centerInd+1};
% spanInd = find(strcmpi(seq{ii},'span')); %Sweep span
% spanVal = seq{ii}{spanInd+1};
% UpTimeInd = find(strcmpi(seq{ii},'UpTime')); %Sweep up time
% UpTimeVal = seq{ii}{UpTimeInd+1};
% multiplyerInd = find(strcmpi(seq{ii},'multiplyer'));%multiplyer (for locking)
p.trapTime = 40e3;
span = 100;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'SetupDDSSweepCentSpan','channel',2,'center',probeDetToFreq(0,1),'span',span,'UpTime',1000,'multiplyer',8});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'pause','duration',p.trapTime});
p.s.addBlock({'TrigScope'});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','value','high','duration',1000});
p.s.run();


