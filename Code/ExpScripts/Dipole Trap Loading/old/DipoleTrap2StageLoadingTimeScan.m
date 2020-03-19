clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='DipoleTrap2StageLoadingTimeScan';
p.hasScopResults=1;
p.hasPicturesResults=0;
p.picsPerStep=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.probeRampTime = 20;
p.probeRampSpan = 75;
p.probeLockCenter = 400;
initinst
initr
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,2)
%%
%1st stage params
p.DTParams.LoadingTime = 1e5;
p.MOTReleaseTime = 300;
p.DTParams.TrapTime = 4e4;
p.DTParams.repumpLoadingPower = 0.057;
p.DTParams.coolingLoadingPower = 55;
p.DTParams.coolingLoadingDetuning = -20;
p.DTParams.MOTLoadTime = 2e6;
%2nd Stage params

p.secondStageCoolingDet = -75;
p.secondStageCoolingPower = 350;
p.secondStageRepumpPower = 0.042;
p.loopVals{1} = linspace(1e4,1e5,10);
p.loopVars{1} = 'secondStageTime';
p.(p.loopVars{1}) = p.INNERLOOPVAR;

% p.loopVals{2} = linspace(1,1000,2);
% p.loopVars{2} = 'tofTime';
% p.(p.loopVars{2}) = p.OUTERLOOPVAR;
% p.secondStageTime = 20e3;
% p.secondStageTime = 1;

%scan params
p.tofTime = 1000;
p.DepumpTime = 400;

%setup params
p.coolingDet = p.DTParams.coolingDet;
p.circCurrent = p.DTParams.circCurrent;
p.MOTLoadTime = p.DTParams.MOTLoadTime;
p.coolingDet = p.DTParams.coolingDet;
p.circCurrent = p.DTParams.circCurrent;

%sequence
p.s = sqncr;
%Turn off control and probe
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'});
%1st stage loading
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.DTParams.repumpLoadingPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.DTParams.coolingLoadingDetuning});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.DTParams.coolingLoadingPower});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.DTParams.LoadingTime});
%2nd stage loading
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.secondStageCoolingDet});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.secondStageCoolingPower});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.secondStageRepumpPower});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.secondStageTime})
%turn off mot and trap
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setAnalogChannel','channel','CircCoil','duration',0,'value',0});
p.s.addBlock({'pause','duration',100});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'pause','duration',p.DTParams.TrapTime});

%realse trap and tof
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'endOfSeqToF'});
p.s.addBlock({'pause','duration',p.tofTime});
%scan
p.s.addBlock({'probeAOMTriangularScan'});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run
%
figure;
ax = gca;
hold on;
for ii = 1:length(p.loopVals{1})
    if length(p.loopVals)>1
        for jj = 1:length(p.loopVals{2})
            [freq,startInds,endInds]=getDDSTriangleRampFreqVec(r.scopeRes{1}(:,1,jj,ii),r.scopeDigRes{1}(:,9,jj,ii),p.probeRampSpan,0);
            absor{:,jj,ii} = r.scopeRes{1}(startInds(1):endInds(1),5,jj,ii)./fliplr(r.scopeRes{1}(startInds(2):endInds(2),5,jj,ii)')';
            plot(freq+(ii-1)*p.probeRampSpan,absor{:,jj,ii})
        end
    else
        [freq,startInds,endInds]=getDDSTriangleRampFreqVec(r.scopeRes{1}(:,1,ii),r.scopeDigRes{1}(:,9,ii),p.probeRampSpan,0);
        absor{:,ii} = r.scopeRes{1}(startInds(1):endInds(1),5,ii)./fliplr(r.scopeRes{1}(startInds(2):endInds(2),5,ii)')';
        plot(freq+(ii-1)*p.probeRampSpan,absor{:,ii})
    end
end
ylim([0,1.3]);

%%
% [OD,coofs] = getODFromProbeScan(r,p);
% figure;
% imagesc(p.loopVals{1},p.loopVals{2},OD)