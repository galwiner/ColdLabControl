clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='SPCM776EIT';
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
p.messTime = 100;
p.repumpTime = 20;
p.NAverage = 1;
p.TTbinsPerStep=100;
p.probeNDList=[1,3];
p.probePower=1e-10;
p.DTParams.TrapTime = 3e4;
p.loopVals{1} = linspace(-50,50,50);
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.Buffer_size = 1e4;
p.s = sqncr;
p.s.addBlock({'startTTrawShort','Buffer_size',p.Buffer_size});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','value','low','duration',0});
p.s.addBlock({'pause','duration',5e3}); %shutter close delay
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'});
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
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

p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',10});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',100});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',100});
p.s.addBlock({'pause','duration',100});
p.s.addBlock({'forEnd','value',p.TTbinsPerStep});
p.s.addBlock({'GenPause','duration',1e6}); 
p.s.run
%%

RowData = r.ttRowData{1};
for ii = 1:length(p.loopVals{1})
    tmpData = r.ttRowData{ii};
   counts(ii) =  tmpData.tagTimestamps.Length;
end
figure;
plot(counts)
% maxInd = RowData.tagTimestamps.Length;
% for ii = 1:maxInd
%     if RowData.tagChannels(ii)==1
%         if ~exist('countTimes','var')
%             countTimes = RowData.tagTimestamps(ii);
%         else
%         countTimes(end+1) = RowData.tagTimestamps(ii);
%         end
%     end
% end

