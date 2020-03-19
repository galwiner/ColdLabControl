clear all
instrreset
global p
global r
global inst
DEBUG=0;
initp
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

p.looping=1;
p.expName = 'ProbePulsingTest';
%%
%operations to run once

p.probeDet = -5;
p.s=sqncr();
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'startTTraw','Buffer_size',1e5,'chan1',1,'chan2',2});
p.s.addBlock({'setDigitalChannel','channel','ProbeShutter','value','high','duration',0});
p.s.addBlock({'Load MOT'});
p.s.runStep;

p.NAverage = 20;
p.DTParams.TrapTime = 1e3;
% p.loopVals{1} = linspace(5e4,1e6,1);
% p.loopVars{1} = 'DTParams.TrapTime';
% p.DTParams.TrapTime = p.INNERLOOPVAR;
p.tofTime = 1;
p.DTParams.MOTLoadTime = 1;
p.MOTReloadTime = 1;
p.slowModePost = 1;
p.pauseBetweenRunSteps = 0.001;
p.TTbinsPerStep=10000;
p.probeNDList = [1,3];
p.Control776NDList = 2;
p.controlPower = 0.02;
p.reTrapTime = 20;
p.s=sqncr();
p.s.addBlock({'set776ControlPower','channel','ImagingVVAN','value',p.controlPower,'duration',0});
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
% %tof
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'pause','duration',p.tofTime});

%measure
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
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
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();
%%
% for kk = 1:length(p.loopVals{1})
% for ii =1:p.NAverage
%     try
%     tmpChN_phot_time = r.chN_phot_time{1,1,kk,ii};
%     
%     
%     if isempty(tmpChN_phot_time)||isempty(tmpChN_phot_time{1})||isempty(tmpChN_phot_time{2})
%         photCount(ii,:,kk) = nan(1,p.TTbinsPerStep);
%         continue
%     end
%     if length(tmpChN_phot_time{1})~=p.TTbinsPerStep||length(tmpChN_phot_time{2})~=p.TTbinsPerStep
%                 photCount(ii,:,kk) = nan(1,p.TTbinsPerStep);
%         continue
%     end
%     for jj = 1:p.TTbinsPerStep
%       photCount(ii,jj,kk) = length(tmpChN_phot_time{1}{jj})+length(tmpChN_phot_time{2}{jj});
%     end
%     catch err
%         warning('an error acured at ii=%1f,jj=%1f,kk=%1f. %s\n',ii,jj,kk,err.message);
%     end
% end
% end
% meanphotCount = squeeze(nanmean(photCount,1));
% figure;   
% for ii=1:length(p.loopVals{1})
%     subplot(4,3,ii)
% plot(meanphotCount(:,ii))
% title(sprintf('Trap time = %0.2d ms',p.loopVals{1}(ii)*1e-3))
% end
%%
for ii = 1:p.NAverage
    if isempty(r.chN_phot_time{ii})
       numofPulses(ii,:) = 0;
       continue;
    end
    numofPulses(ii,1) = length(r.chN_phot_time{ii}{1});
    numofPulses(ii,2) = length(r.chN_phot_time{ii}{2});

end
%%
for kk = 1:length(p.loopVals{1})
for ii =1:p.NAverage
tmpChN_phot_time = shiftedPulses{1,kk,ii};

if isempty(tmpChN_phot_time)
    fprintf('empty pulse data at kk=%.0f and ii=%.0f\n',kk,ii);
    continue
end
if isempty(tmpChN_phot_time{1})
    fprintf('empty pulse data in detector 1 at kk=%.0f and ii=%.0f\n',kk,ii);
end
if isempty(tmpChN_phot_time{2})
    fprintf('empty pulse data in detector 2 at kk=%.0f and ii=%.0f\n',kk,ii);
end
%     if isempty(tmpChN_phot_time)||isempty(tmpChN_phot_time{1})||isempty(tmpChN_phot_time{2})
%         photCount(ii,:,kk) = nan(1,p.TTbinsPerStep);
%         continue
%     end
%     if length(tmpChN_phot_time{1})~=p.TTbinsPerStep||length(tmpChN_phot_time{2})~=p.TTbinsPerStep
%                 photCount(ii,:,kk) = nan(1,p.TTbinsPerStep);
%         continue
%     end
%     for jj = 1:p.TTbinsPerStep
%       photCount(ii,jj,kk) = length(tmpChN_phot_time{1}{jj})+length(tmpChN_phot_time{2}{jj});
%     end
%     catch err
%         warning('an error acured at ii=%1f,jj=%1f,kk=%1f. %s\n',ii,jj,kk,err.message);
%     end
end
end
% meanphotCount = squeeze(nanmean(photCount,1));
% figure;   
% for ii=1:length(p.loopVals{1})
%     subplot(4,3,ii)
% plot(meanphotCount(:,ii))
% title(sprintf('Trap time = %0.2d ms',p.loopVals{1}(ii)*1e-3))
% end