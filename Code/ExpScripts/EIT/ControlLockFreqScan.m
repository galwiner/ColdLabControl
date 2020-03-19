clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='ControlLockFreqScan';
p.hasScopResults=1;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.probeRampTime = 3000;
p.probeRampSpan = 75;
p.probeLockCenter = probeDetToFreq(20,1);
% p.probeLockCenter = probeDetToFreq(3,1);
initinst
initr
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8)
%%
p.DTParams.LoadingTime = 1e5;
p.DTParams.TrapTime = 2e4;
p.DTParams.repumpLoadingPower = 0.044;
p.DTParams.coolingLoadingPower = 55;
p.DTParams.coolingLoadingDetuning = -20;
p.DTParams.LoadingTime =  20e3;
p.trigPulseTime = 10;
% p.secondStageCoolingDet = -55;
% p.secondStageCoolingPower = 80;
p.secondStageRepumpPower = 0.05;

p.secondStageTime = 1;
p.loopVals{1} = linspace(370,370,1);
p.loopVars{1} = 'controlFreq';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.TofTime = 1500;
p.TofTime = 20;
% p.TOFtimes = [1,5,10,15]*1e3;
p.coolingDet = p.DTParams.coolingDet;
p.circCurrent = p.DTParams.circCurrent;
p.DTPic = p.DTParams.DTPic;
p.MOTLoadTime = p.DTParams.MOTLoadTime;
p.coolingDet = p.DTParams.coolingDet;
p.circCurrent = p.DTParams.circCurrent;
p.DTPic = p.DTParams.DTPic;
p.DepumpTime = 400;
p.MOTLoadTime = p.DTParams.MOTLoadTime;
p.DTParams.LoadingTime = 40e3;
p.s = sqncr;
p.s.addBlock({'setDDSfreq','channel',1,'freq',p.controlFreq});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'});
p.s.addBlock({'LoadDipoleTrap'})
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'endOfSeqToF'});
p.s.addBlock({'pause','duration',p.TofTime});
% p.s.addBlock({'TakePic'});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',p.probeRampTime+50,'value','high'});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run
%%
%     ii = 1;
    figure

for jj = 1:length(p.loopVals{2})
    subplot(4,3,jj)
    hold on
for ii =1:length(p.loopVals{1}) 
[Upfreq,UpStartInd,UpEndInd] = getDDSUpRampFreqVec(r.scopeRes{1}(:,1,jj,ii),r.scopeDigRes{1}(:,3,jj,ii),r.scopeDigRes{1}(:,9,jj,ii),75/2,200);
[Downfreq,DownStartInd,DownEndInd] = getDDSDownRampFreqVec(r.scopeRes{1}(:,1,jj,ii),r.scopeDigRes{1}(:,3,jj,ii),r.scopeDigRes{1}(:,9,jj,ii),75/2,200);
data = r.scopeRes{1}(UpStartInd:UpEndInd,5,jj,ii);
% data = smooth(data,100);
bg = fliplr(r.scopeRes{1}(DownStartInd:DownEndInd,5,jj,ii)')';
% bg = smooth(bg,100);
% bg = (r.scopeRes{1}(DownStartInd:DownEndInd,5,ii));
if length(bg)>length(data)
    bg((length(data)+1):end) = [];
elseif length(bg)<length(data)
    data((length(bg)+1):end) = [];
    Upfreq((length(bg)+1):end) = [];
end
absor{:,jj,ii} = data./bg;
try
    if ~isempty(absor{:,jj,ii})
        plot(Upfreq+(ii-1)*20,absor{:,jj,ii})
    else
        continue
    end
catch
   error('error on ii=%d, jj=%d',ii,jj) 
end
% plot(Upfreq,absor{:,ii})
end
end
%%
[OD,coofs] = getODFromProbeScan(r,p);
figure;
imagesc(p.loopVals{1},p.loopVals{2},OD)