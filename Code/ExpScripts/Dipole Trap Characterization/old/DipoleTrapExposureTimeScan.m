

%cooling power sweep with fast mode spectroscopy
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.expTimes = linspace(30,350,10);
for ii = 1:length(p.expTimes)
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep = 1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=1;
p.DTPic = 1;
p.DEBUG=DEBUG;
p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
p.cameraParams{1}.E2ExposureTime = p.expTimes(ii);
p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
p.cameraParams{2}.E2ExposureTime = 50;
p.NAverage = 5;

% p.HHYCurrent = -100e-3;
% p.HHZCurrent = -30e-3;
initinst
initr
p.expName = 'Dipole Trap exposure time scan';
%% 
% p.loopVars{1} = 'expTime';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.loopVals{1} = linspace(30,400,10);
p.trapTime = 40e3;
p.DTParams.MOTLoadTime = 6e6;
p.s=sqncr();
% p.s.addBlock({'setCamExp','expTime',p.expTime})
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'pause','duration',p.trapTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.run();
end
% r.images{1} = mean(r.images{1},6);
% p.NAverage = 1;
% p.GaussianFitThreshold = 0.3;
% p.s.fitAll;
% customsave;
%
% figure;
% plot(p.loopVals{1},squeeze(r.atomDensity{1}));
% imageViewer(r.images{1})
% imageViewer(r.images{2})
% figure;
% yyaxis left
% plot(p.loopVals{1},squeeze(r.atomDensity{1}))
% yyaxis right
% plot(p.loopVals{1},squeeze(r.atomNum{1}))
% figure;
% plot(p.loopVals{1},squeeze(r.fitParams{1}(5,:)))
% hold on
% plot(p.loopVals{1},squeeze(r.fitParams{1}(6,:)))