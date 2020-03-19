clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='g2';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
p.hasScopResults=0;
p.hasPicturesResults=0;
p.hasTTresults=1;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr

%%
% inst.DDS.setFreq(1,341.6,0,0);
p.repumpTime = 20;
p.NAverage = 1;
p.TTbinsPerStep=100;
p.probeNDList=[1,3];
% p.probePower=1e-10;
% chan1ind = find(strcmpi(seq{ii},'chan1'));
%                         chan1 = seq{ii}{chan1ind+1};
%                         chan2ind = find(strcmpi(seq{ii},'chan2'));
%                         chan2 = seq{ii}{chan2ind+1};
%                         gateChanind = find(strcmpi(seq{ii},'gate'));
%                         gateChan = seq{ii}{gateChanind+1};
%                         bin_widthind= find(strcmpi(seq{ii},'binwidth'));
%                         bin_width = seq{ii}{bin_widthind+1}*1e6;
%                         n_binsind= find(strcmpi(seq{ii},'n_bins'));
%                         n_bins = seq{ii}{n_binsind+1};

p.probeDet = -2.5;
p.NAverage = 1;
p.g2BinWidth = 1e-1; %in mus
p.g2BinNum = 1e3/p.g2BinWidth; %to get the length of thime of the measurement
p.DTParams.TrapTime = 3e4;
p.loopVals{1} = linspace(1e-10,1e-10,1);
p.loopVars{1} = 'probePower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s = sqncr;
p.s.addBlock({'startTTgatedCount','countVectorLen',p.TTbinsPerStep});
p.s.addBlock({'startTTcorrelation','chan1',1,'chan2',2,'gate',3,'binwidth',p.g2BinWidth,'n_bins',p.g2BinNum});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0}); %Blue light shutter off
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0}); %Blue light AOM on
p.s.addBlock({'pause','duration',5e3}); %shutter close delay
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','high','duration',0}); %open the shutter but switch off the blue light
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',5e3}); %shutter open delay
%repump
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.repumpTime});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',1e3});
%measure
p.s.addBlock({'forStart'});

p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'TrigScope'});

p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',10});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',100});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',100});
p.s.addBlock({'pause','duration',100});
p.s.addBlock({'forEnd','value',p.TTbinsPerStep});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0}); %Blue AOM on but shutter off.(keeping AOM hot)
p.s.addBlock({'GenPause','duration',1e6}); 
p.s.run

data = r.cnt;
figure;
plot(r.corrRes./(p.g2BinWidth*sum(r.cnt(1,:))*sum(r.cnt(3,:))))
%get Bg
% p.s = sqncr;
% p.s.addBlock({'startTTgatedCount','countVectorLen',p.TTbinsPerStep});
% p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
% p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
% p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
% p.s.addBlock({'pause','duration',5e3}); %shutter open delay
% %measure
% p.s.addBlock({'forStart'});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',10});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',10});
% p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',10});
% p.s.addBlock({'pause','duration',10});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',100});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',100});
% p.s.addBlock({'pause','duration',100});
% p.s.addBlock({'forEnd','value',p.TTbinsPerStep});
% p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','low','duration',0});
% p.s.addBlock({'pause','duration',5e3}); %shutter close delay
% p.s.addBlock({'GenPause','duration',0.1e6}); 
% p.s.run
% bg = r.cnt;
%%
