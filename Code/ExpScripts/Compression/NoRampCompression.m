clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='No Ramp Compression';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=1;
if p.picsPerStep == 1 ||p.picsPerStep == 2
    p.calcTemp = 0;
else
    p.calcTemp = 1;
end
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{1}.E2ExposureTime=100;
p.cameraParams{2}.E2ExposureTime=30;
p.cameraParams{1}.ROI = [720,485,200,190];
p.cameraParams{2}.ROI = [310,460,110,200];
p.DEBUG=DEBUG;
%
initinst
initr

p.s.getbgImg;
%%  
% f1 = figure;
% ax1 = axes;
% f2 = figure;
% ax2 = axes;
MotPosPlane  = [100,99];
MotPosTop  = [73,107];
p.DTPic = 1;
% p.GaussianFitThreshold = 0.1;
p.MOTLoadTime = 4e6;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
% p.compressionEndCurrent=220;
% p.TOFtimes = [5,10,15,20]*1e3;
% p.MOTReloadTime = 500e3;
p.compressionRampTime = 40e3; %in us
p.PGCPower = 50;
p.PGCTime = 10;
p.PGCDetuning = -75;
% p.PGCPower2 = 10;
% p.PGCTime2 = 500;
% p.PGCDetuning2 = -85;
p.loopVars{1} = 'PGCTime';
p.loopVals{1} = linspace(100,10e3,10);
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.trapTime = 15e3;
p.CompressioncircCurrent = 220;
p.compressionTime = 3e3; 
p.compressionDetuning = -55;
p.CompressionPower = 200;
p.repumpDetuning = 5.5;
% for ii = 1:50
% t = tic;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setCircCurrent','channel','CircCoil','duration',0,'value',p.CompressioncircCurrent});
p.s.addBlock({'pause','duration',p.compressionRampTime});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.CompressionPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.compressionDetuning});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',p.repumpDetuning});
p.s.addBlock({'pause','duration',p.compressionTime});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.PGCDetuning});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.PGCPower,'description','Load MOT: set cooling power'});
p.s.addBlock({'pause','duration',p.PGCTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'Release MOT'});
% p.s.addBlock({'pause','duration',15e3});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',p.PGCTime2,'inverted','true'});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',p.PGCTime2,'inverted','true'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime2,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime2,'value','high'});
% p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.PGCDetuning2});
% p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
% p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.PGCPower2,'description','Load MOT: set cooling power'});
% p.s.addBlock({'pause','duration',p.PGCTime2});
p.s.addBlock({'pause','duration',p.trapTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'GenPause','duration',200e3});
% p.s.addBlock({'endOfSeqToF'});
p.looping = int16(1);
p.s.run();
%
% imagesc(ax1,r.images{1});
% colorbar;
% hold(ax1,'on');
% plot(ax1,MotPosPlane(1),MotPosPlane(2),'rx');
% hold(ax1,'off');
% title(sprintf('Density = %0.2d',r.atomDensity{1}))
% imagesc(ax2,r.images{2});
% colorbar;
% hold(ax2,'on');
% plot(ax2,MotPosTop(1),MotPosTop(2),'rx');
% hold(ax2,'off');
% title(sprintf('Density = %0.2d',r.atomDensity{1}))
% time =toc(t);
% diff = (p.MOTLoadTime+200e3)*1e-6-time;
% if (diff>0)
%     pause(diff)
% end
% end
if ~isempty(p.loopVals)
    figure;
    yyaxis left
    plot(p.loopVals{1},squeeze(r.atomDensity{1}))
    yyaxis right
    plot(p.loopVals{1},squeeze(r.fitParams{1}(5,:)))
    hold on
    plot(p.loopVals{1},squeeze(r.fitParams{1}(6,:)))
else
disp(sprintf('Density %0.2d. size [%0.2d,%0.2d]',r.atomDensity{1},r.fitParams{1}(5,:),r.fitParams{1}(6,:)));
end
% imageViewer(r.images{1});
% imageViewer(r.images{2});
% disp(sprintf('density = %0.2d',r.atomDensity{1}));