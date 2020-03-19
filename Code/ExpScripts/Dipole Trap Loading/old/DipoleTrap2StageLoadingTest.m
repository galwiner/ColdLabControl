clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='DipoleTrap2StageLoadingTest';
p.hasScopResults=1;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp = 0;
p.cameraParams{1}.B1BinningHorizontal = '04';
p.cameraParams{1}.B2BinningVertical = '04';
p.cameraParams{2}.B1BinningHorizontal = '04';
p.cameraParams{2}.B2BinningVertical = '04';
p.cameraParams{2}.ROI = round(p.cameraParams{2}.ROI/4);
p.cameraParams{1}.ROI  =round(p.cameraParams{1}.ROI/4);
p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{2}.E2ExposureTime=1e3;
p.DEBUG=DEBUG;
p.probeRampTime = 1000;
p.probeRampSpan = 75;
% p.probeLockCenter = probeDetToFreq(0,1);
p.probeLockCenter = 400;

initinst
initr
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2)
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
p.loopVals{1} = linspace(-58.3,-58.3,1);
p.loopVars{1} = 'secondStageCoolingDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
% 
p.loopVals{2} = linspace(188.9,188.9,1);
p.loopVars{2} = 'secondStageCoolingPower';
p.(p.loopVars{2}) = p.OUTERLOOPVAR;
% p.secondStageTime = 20e3;
p.secondStageTime = 1;
% p.secondStageTime = 1;
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
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.DTParams.repumpLoadingPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.DTParams.coolingLoadingDetuning});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.DTParams.coolingLoadingPower});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.DTParams.LoadingTime});

p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.secondStageCoolingDet});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.secondStageCoolingPower});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.secondStageRepumpPower});
p.s.addBlock({'pause','duration',p.secondStageTime})
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setAnalogChannel','channel','CircCoil','duration',0,'value',0});
p.s.addBlock({'pause','duration',p.DTParams.TrapTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'endOfSeqToF'});
p.s.addBlock({'pause','duration',p.TofTime});
% p.s.addBlock({'TakePic'});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.probeRampTime});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.DepumpTime});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
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