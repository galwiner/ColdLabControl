clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='Dipole Trap parametric heating';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=0;
if p.picsPerStep == 1 ||p.picsPerStep == 2
    p.calcTemp = 0;
%     p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
%     p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
    p.cameraParams{1}.B1BinningHorizontal = '04';
    p.cameraParams{1}.B2BinningVertical = '04';
        p.cameraParams{2}.B1BinningHorizontal = '04';
        p.cameraParams{2}.B2BinningVertical = '04';
%     p.cameraParams{2}.ROI = p.cameraParams{2}.ROI/4;
        p.cameraParams{2}.ROI = round(calculateROI(p.DTPos{2}(1),p.DTPos{2}(2),200,200)/4);
%         p.cameraParams{1}.ROI = p.cameraParams{1}.ROI/4;
        p.cameraParams{1}.ROI  =[100,80,220,160];
else
    p.calcTemp = 1;
    p.cameraParams{1}.B1BinningHorizontal = '04';
    p.cameraParams{1}.B2BinningVertical = '04';
    p.cameraParams{1}.ROI = [100,100,250,100];
end

p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{2}.E2ExposureTime=1e3;
% p.cameraParams{1}.ROI = [0,0,1392/4,1040/4];
% p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
p.DEBUG=DEBUG;
%
p.FunctionGen = 1;
initinst
initr

%%
% p.s.getbgImg;
p.FitPos{1} = [100,100]*8.5575e-06;
scale = 8.5575e-06*3.047*4;
p.FitPos{2} = [17,17]*scale;
p.GaussianFitThreshold = 0.3;
p.flashTime = 150;
p.DTParams.LoadingTime = 1e5;
p.DTParams.TrapTime = 0.5e5;
p.tofTime = 3e3;
p.oscTime = 70e3;
p.loopVars{1} = 'oscFreq';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.loopVals{1} = linspace(1300,1800,20);
AmpFactor = 5.45;
%max power at 10 V (7.4W), 80% at 5.6V (5.9W)
bias = 10;
modulation = (10-4.5)*2;
% p.NAverage = 2;
% modulation = 0.1;
initr
p.s = sqncr;
p.s.addBlock({'setRigolModParams','channel',1,'bias',bias/AmpFactor,'modulation',modulation/AmpFactor,'freq',p.oscFreq});
p.s.addBlock({'setRigolBurstMode','channel',1,'mode','gat'});
p.s.addBlock({'setRigolBurstState','channel',1,'state',1});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','RigolTTL','value','high','duration',p.oscTime});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',p.oscTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'TakePic'});
p.s.run
% imageViewer(r.images{2})
%
atomNum = squeeze(sum(sum(r.images{2},1),2))-200*size(r.images{2},1)*size(r.images{2},2);
atomNum = getAtomNum(atomNum,'top');

% figure;
% subplot(2,1,1)
% plot(p.loopVals{1},atomNum)
% subplot(2,1,2)
% yyaxis left
% plot(p.loopVals{1},r.fitParams{2}(5,:));
% yyaxis right
% plot(p.loopVals{1},r.fitParams{2}(6,:));
% imageViewer(r.images{2}(:,:,:)-r.bgImg{2})
imageViewer(r.images{1}(:,:,:))
%%
ycut = (r.images{1}(:,111,:,:,:,:));
meanycut = squeeze(mean(ycut,6));
initparams = [80,70,10,230];
x = 1:size(meanycut,1);
for ii=1:size(meanycut,2)
%     figure;
    [fitobject,fitParams(:,ii),fitFunc,gof,output] = fit1DGaussian(x,meanycut(:,ii),initparams);
%     plot(x,meanycut(:,ii))
%     hold on
%     plot(fitobject)
end
figure;
plot(p.loopVals{1},fitParams(3,:))

% plot(ycut);
% hold on
% plot(fitobject)
%%
%%
%Old seq
% p.FitPos{1} = [0.007209,0.005017];
% p.FitPos{2} = [0.001321,0.009103];
% p.MOTReloadTime = 0.5e6;
% p.GaussianFitThreshold = 0.5;
% p.flashTime = 150;
% p.NAverage = 1;
% p.DTPic = 1;
% p.MOTLoadTime = 6e6;
% p.coolingDet = -4*p.consts.Gamma;
% p.circCurrent = 20;
% p.TOFtimes = [5,10,15,20]*1e3;
% p.compressionRampTime = 40e3; %in us
% p.PGCPower = 500;
% p.PGCTime = 3e3;
% p.PGCDetuning = -54;
% p.CompressioncircCurrent = 80;
% % p.expTime = 1500;
% p.NAverage = 1;
% p.loopVars{1} = 'oscPeriod';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.loopVals{1} = linspace(1500,3000,20);
% initr
% p.trapTime = 30e3;
% p.compressionTime = 8e3;
% p.compressionDetuning = -80;
% p.repumpDetuning = 5.5;
% p.CompressionPower = 1000;
% p.oscTime = 40e3;
% p.s=sqncr();
% % p.s.addBlock({'Load MOT'});
% p.s.addBlock({'setRigolModParams','channel',1,'bias',5,'modulation',1,'freq',p.oscPeriod});
% p.s.addBlock({'setRigolBurstMode','channel',1,'mode','gat'});
% p.s.addBlock({'setRigolBurstState','channel',1,'state',1});
% p.s.addBlock({'pause','duration',1e6});
% p.s.addBlock({'setRepumpDetuning','duration',0,'value',p.repumpDetuning});
% p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.CompressionPower});
% p.s.addBlock({'setCircCurrent','channel','CircCoil','duration',0,'value',p.CompressioncircCurrent});
% p.s.addBlock({'pause','duration',p.compressionRampTime});
% p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.compressionDetuning});
% p.s.addBlock({'pause','duration',p.compressionTime});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
% % p.s.addBlock({'pause','duration',15e3});
% p.s.addBlock({'TrigScope'});
% p.s.addBlock({'Release MOT'});
% p.s.addBlock({'pause','duration',p.trapTime});
% p.s.addBlock({'setDigitalChannel','channel','RigolTTL','value','high','duration',p.oscTime});
% p.s.addBlock({'pause','duration',p.oscTime});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% p.s.addBlock({'pause','duration',2e3});
% p.s.addBlock({'TakePic'});
% p.s.addBlock({'Reload MOT'});
% p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
% % p.s.addBlock({'endOfSeqToF'})
% p.looping = int16(1);
% p.s.run();
% %
% imageViewer(r.images{2},r.x{2},r.y{2});
% % imageViewer(r.images{2});
% % intCounts = sum(reshape(r.images{2},size(r.images{2},1)*size(r.images{2},2),size(r.images{2},5),size(r.images{2},6))-200,1);
% % intCountsMean = mean(intCounts,3);
% % intCountsSTD = std(intCounts,[],3);
% % atomNumMean = squeeze(mean(r.atomNum{2},4));
% % atomNumSTD = squeeze(std(r.atomNum{2},[],4));
% % figure;
% % errorbar(p.loopVals{1},intCountsMean,intCountsSTD)
% % figure;
% % errorbar(p.loopVals{1},atomNumMean,atomNumSTD)
% figure;
% yyaxis left
% plot(p.loopVals{1},r.fitParams{2}(6,:));
% yyaxis right
% plot(p.loopVals{1},squeeze(r.atomNum{2}));