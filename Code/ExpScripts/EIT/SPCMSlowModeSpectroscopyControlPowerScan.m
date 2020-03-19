clear all
instrreset
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=0;
p.hasTTresults = 1;
p.hasPicturesResults = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
inst.tt.setTriggerLevel(1,0.5)
p.looping=1;
p.expName = 'SPCMSlowModeSpectroscopyControlPowerScan';
%%
p.stepTime = 1;
p.freqNum = 50;
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 10;
p.probeDet = -2;
p.probeLockCenter = 400+p.probeDet;
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2,0,1e-1*p.freqNum,p.freqNum)
p.s=sqncr();
% p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'startTTraw','Buffer_size',1e5,'chan1',1,'chan2',2});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
p.s.addBlock({'Load MOT'});
p.s.runStep;
p.NAverage = 5;
p.repumpTime = 1;
% p.DTParams.secondStageTime = 5e3;
% p.DTParams.LoadingTime = 5e4;
p.DTParams.TrapTime = 1e6;
p.DTParams.MOTLoadTime = 1;
p.MOTReloadTime = 1;
p.chanList = 4;
p.slowModePost = 1;
p.pauseBetweenRunSteps = 0.001;
p.TTbinsPerStep=500;
% p.probeDet =0;
p.loopVals{2} = linspace(2e-3,0.02,1);
% p.loopVals{2} = linspace(1e-2,1e-2,1);
p.loopVars{2} = 'controlPower';
p.(p.loopVars{2}) = p.OUTERLOOPVAR;

p.loopVals{1} = ((1:p.freqNum)-1)*p.stepTime;
p.loopVars{1} = 'freqJumpPause';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.freqs = linspace(-p.probeRampSpan/2,p.probeRampSpan/2,length(p.loopVals{1}));
p.messTime = 15;
p.probeNDList = [1,3];
p.Control776NDList = 2;
p.reTrapTime = 10;
p.s=sqncr();
p.s.addBlock({'set776ControlPower','channel','ImagingVVAN','value',p.controlPower,'duration',0});
p.s.addBlock({'syncSetProbeAOMFreq','freqJumpPause',p.freqJumpPause});
% p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
% p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
% p.s.addBlock({'pause','duration',1e4});
p.s.addBlock({'setProbePower','duration',0,'value',1e-9,'channel','PRBVVAN'})
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
%repump
for ii = 1:10
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high','description','REPUMP OFF'});
p.s.addBlock({'pause','duration',40});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','REPUMP OFF'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',100});
end

%measure
p.s.addBlock({'forStart'});

p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'TrigScope'});

p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',10});
p.s.addBlock({'setDigitalChannel','channel','TTGate','value','high','duration',10});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',p.reTrapTime});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',p.reTrapTime});
p.s.addBlock({'pause','duration',p.reTrapTime});
p.s.addBlock({'forEnd','value',p.TTbinsPerStep});


p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e5});
p.s.run();
%%
incomingPhotonRate = 68.27;
for ii = 1:p.freqNum 
    for jj = 1:length(p.loopVals{2})
        for kk = 1:p.NAverage
        rawData = r.rawTTData(1,1,jj,ii,kk);
        rawData = rawData{1};
        det1PhotonCount(jj,ii,kk) = length(find(rawData(2,:)==1))/p.TTbinsPerStep;
        if det1PhotonCount(jj,ii,kk)==0
            det1PhotonCount(jj,ii,kk) = nan;
        end
        det2PhotonCount(jj,ii,kk) = length(find(rawData(2,:)==2))/p.TTbinsPerStep;
        if det2PhotonCount(jj,ii,kk)==0
            det2PhotonCount(jj,ii,kk) = nan;
        end
        
%     if isempty(r.chN_phot_time{1,jj,ii})
%         photNum(jj,ii,:) = nan(1);
%         continue
%     end
%     tmpData = getPhotonsPerGate(r.chN_phot_time{1,jj,ii}{1});
%     if length(tmpData)~=p.TTbinsPerStep
%         continue
%     end
% photNum(jj,ii,:) = mean(tmpData);
    end
    end
end
totPhotonCnt = det2PhotonCount+det1PhotonCount;
totPhotonCnt = nanmean(totPhotonCnt,3);
figure;
plot(p.freqs,totPhotonCnt/incomingPhotonRate)
