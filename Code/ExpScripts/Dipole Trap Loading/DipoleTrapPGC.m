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
initinst
initr
p.expName = 'Dipole Trap PGC';
%% 
p.DTParams.MOTLoadTime = 6e6;
% p.DTParams.repumpDetuning = 12;
% p.PGCPower = 150;
p.PGCTime = 3e3;
p.PGCDetuning = -84;
p.repNum = 100;
p.loopVals{1} = linspace(50,300,2);
p.loopVars{1} = 'PGCPower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.trapTime = 20e3;
p.s=sqncr();
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'pause','duration',20e3});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.PGCDetuning});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.PGCPower,'description','Load MOT: set cooling power'});
% p.s.addBlock({'setRepumpDetuning','duration',0,'value',12});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime,'value','High'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime,'value','High'});
% p.s.addBlock({'forStart'});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime,'value','High'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime,'value','High'});
p.s.addBlock({'pause','duration',p.PGCTime});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
% p.s.addBlock({'forEnd','value',p.repNum});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.trapTime});
p.s.addBlock({'TakePic'});
p.s.run();

%
figure;
yyaxis left
plot(p.loopVals{1},squeeze(r.atomDensity{1}));
yyaxis right
plot(p.loopVals{1},r.fitParams{1}(5,:));
hold on
plot(p.loopVals{1},r.fitParams{1}(6,:));
% imageViewer(r.images{1})
% imageViewer(r.images{2})
% fprintf('Densiy = %0.2d. Size = [%0.2d,%0.2d]\n',r.atomDensity{1},r.fitParams{1}(5),r.fitParams{1}(6));