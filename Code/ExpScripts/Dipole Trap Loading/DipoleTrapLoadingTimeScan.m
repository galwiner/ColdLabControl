%cooling power sweep with fast mode spectroscopy
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep = 1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=1;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{2}.B1BinningHorizontal = '01';
p.cameraParams{2}.B2BinningVertical = '01';
p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
initinst
initr
p.expName = 'Dipole Trap loading time scan';
%%
p.flashTime = 150;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
% p.repumpLoadingPower = 0.065;
% p.coolingLoadingDeutuning = -20;
% p.coolingLoadingPower = 30;
% p.TrapTime = 40e3;
p.DTParams.TrapTime = 100e3;
% p.loopVals{1} = [50:50:500,1e3:2e3:40e3,1e5:2e5:2e6]; %Hold Time
p.loopVals{1} = linspace(10e3,100e3,10);
p.loopVars{1} = 'LoadingTime';
p.DTParams.LoadingTime = p.INNERLOOPVAR;
p.NAverage = 1;
% % p.loopVals{2} = linspace(50,600,10); %Hold Time
% % p.loopVars{2} = 'MOTReleaseTime';
% % p.(p.loopVars{2}) = p.OUTERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'TakePic'});
% p.s.addBlock({'Load MOT'});
% p.s.addBlock({'setRepumpPower','duration',0,'value',p.repumpLoadingPower});
% p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.coolingLoadingDeutuning});
% p.s.addBlock({'setCoolingPower','duration',0,'value',p.coolingLoadingPower});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
% p.s.addBlock({'pause','duration',p.DTLoadTime});
% % p.s.addBlock({'Release MOT'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low','description','Release MOT:COOLING OFF'});...
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','Release MOT:REPUMP OFF'})
% p.s.addBlock({'setAnalogChannel','channel','CircCoil','duration',0,'value',0,'description','Release MOT:CURRENT OFF'});...
% p.s.addBlock({'pause','duration',p.TrapTime});
% p.s.addBlock({'TakePic'});
p.looping = int16(1);
p.s.run();
%%
imageViewer(r.images{1})
imageViewer(r.images{2})
% if ~isempty(p.loopVals)
% figure;plot(p.loopVals{1},squeeze(sum(sum(r.images{2},1),2)),'-o')
% else
%     imageViewer(r.images{2})
% end
% atomNum = squeeze(sum(sum(r.images{2},1),2))-200*size(r.images{2},1)*size(r.images{2},2);
% atomNum = getAtomNum(atomNum,'top');
% atomNumMean = mean(atomNum,2);
% atomNumError = std(atomNum,[],2);
% figure;
% subplot(2,2,1)
% errorbar(p.loopVals{1}(1:10),atomNumMean(1:10),atomNumError(1:10),'-o','linewidth',2)
% xlabel('Loading Time [\mus]');
% ylabel('Atom #')
% title('DT Loading Time, short times')
% set(gca,'fontsize',22)
% subplot(2,2,2)
% errorbar(p.loopVals{1}(11:30)*1e-3,atomNumMean(11:30),atomNumError(11:30),'-o','linewidth',2)
% xlabel('Loading Time [ms]');
% ylabel('Atom #')
% title('DT Loading Time, intermidiate times')
% set(gca,'fontsize',20)
% subplot(2,2,[3,4])
% errorbar(p.loopVals{1}*1e-6,atomNumMean,atomNumError,'-o','linewidth',2)
% xlabel('Loading Time [s]');
% ylabel('Atom #')
% title('DT Loading Time')
% % set(gca,'fontsize',22,'yscale','log')
% set(gca,'fontsize',22)


