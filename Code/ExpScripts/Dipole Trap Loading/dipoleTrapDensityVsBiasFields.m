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
p.DTPic = 1;
p.DEBUG=DEBUG;
p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
p.cameraParams{2}.E2ExposureTime = 50;
p.cameraParams{1}.E2ExposureTime = 100;
p.HHYCurrent = -100e-3;
p.HHZCurrent = -30e-3;
initinst
initr
p.expName = 'Dipole Trap density vs bias fields';
%% 
p.scanDirection = 'z';
p.trapTime = 40e3;
curVals = linspace(0,80,15)*1e-3;
p.loopVals{1} = curVals;
p.loopVars{1} = ['HH',upper(p.scanDirection),'Current'];
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'setHH','value',p.(p.loopVars{1}),'direction',p.scanDirection});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'pause','duration',p.trapTime});
p.s.addBlock({'TakePic'});
p.s.run();

%
figure;
plot(p.loopVals{1},squeeze(r.atomDensity{1}));

