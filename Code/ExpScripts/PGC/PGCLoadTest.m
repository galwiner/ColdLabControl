clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='PGC Load Test';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.calcTemp = 0;
    p.cameraParams{1}.B1BinningHorizontal = '04';
    p.cameraParams{1}.B2BinningVertical = '04';
    p.cameraParams{1}.ROI = [0,0,1392/4,1040/4];
p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{2}.E2ExposureTime=1e3;
p.DEBUG=DEBUG;
%
initinst
initr


%%
p.MOTReloadTime = 1.5e6;
p.GaussianFitThreshold = 0.5;
p.flashTime = 150;
p.NAverage = 1;
p.DTPic = 0;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
p.TOFtimes = [1,2,5,10]*1e3;
p.PGCPower = 50;
p.PGCTime = 2e3;
p.PGCDetuning = -46;
p.repumpDetuning = 0;
p.loopVars{1} = 'PGCPower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.loopVals{1} = linspace(10,300,10);
% p.loopVars{1} = 'PGCTime';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.loopVals{1} = linspace(100,5e3,2);
p.loopVars{2} = 'PGCDetuning';
p.(p.loopVars{2}) = p.OUTERLOOPVAR;
p.loopVals{2} = linspace(-70,-30,10);

% p.loopVars{2} = 'compressionDetuning';
% p.(p.loopVars{2}) = p.OUTERLOOPVAR;
% p.loopVals{2} = linspace(-84,-40,2);
% p.loopVars{1} = 'ExpansionTime';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.loopVals{1} = linspace(1,15e3,40);

p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'})
p.s.addBlock({'pause','duration',6e3});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',p.repumpDetuning});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.PGCPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.PGCDetuning});
p.s.addBlock({'pause','duration',p.PGCTime});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'})
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',1e6});
% p.s.addBlock({'Reload MOT'});
% p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
% p.s.addBlock({'endOfSeqToF'})
p.looping = int16(1);
p.s.run();



%% 


dat=squeeze(r.fitParams{1})
% imageViewer(r.images{1});
% imageViewer(r.fitImages{1});
figure;
subplot(2,2,1:2);
imagesc(p.loopVals{1},p.loopVals{2},squeeze(dat(7,:,:)))
xticks(p.loopVals{1})
xtickformat('%.1f')
ytickformat('%.1f')
yticks(p.loopVals{2})
title('atom number')
ylabel('cooling detuning [MHz]')
xlabel('cooling power [mW]')
colorbar
subplot(2,2,3);
imagesc(p.loopVals{1},p.loopVals{2},squeeze(dat(5,:,:)))
title('cloud sigma_x')
ylabel('cooling detuning [MHz]')
xlabel('cooling power [mW]')
xticks(p.loopVals{1})
yticks(p.loopVals{2})
xtickformat('%.1f')
ytickformat('%.1f')

subplot(2,2,4);
imagesc(p.loopVals{1},p.loopVals{2},squeeze(dat(6,:,:)))
title('cloud sigma_y')
ylabel('cooling detuning [MHz]')
xlabel('cooling power [mW]')
xticks(p.loopVals{1})
yticks(p.loopVals{2})
xtickformat('%.1f')
ytickformat('%.1f')

colorbar()

figure;
surf(p.loopVals{1},p.loopVals{2},squeeze(dat(6,:,:)))

% plot(p.loopVals{1}(1:end)*1e-3,dat(6,1:end),'ob-');hold on;plot(p.loopVals{1}(1:end)*1e-3,dat(5,1:end),'or-')
% xlabel('PGC duration [mS]')
% ylabel('cloud dimensions after 15mS')
% title('PGC final cooling power at 50 mW, detunig at -46 MHz');
% subplot(2,1,2)
% plot(p.loopVals{1}(1:end)*1e-3,squeeze(r.atomNum{1}(1:end)),'o-');
% xlabel('PGC duration [mS]')
% ylabel('atom number after 15 mS')
