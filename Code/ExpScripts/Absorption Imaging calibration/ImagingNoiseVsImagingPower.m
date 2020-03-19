clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Imaging Noise vs imaging power';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=2;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=0;
if p.picsPerStep == 1
    p.calcTemp = 0;
else
    p.calcTemp = 1;
end
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{1}.ROI = [500,300,550,650];
p.NAverage = 10;
initinst
initr
%%
p.AbsImgTime = 10;
% p.imagingPower = 200;
p.loopVals{1} = linspace(50,1000,25);
p.loopVars{1} = 'imagingPower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'pause','duration',200e3});
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'GenPause','duration',100e3});
p.s.run();

%%
r.images{1} = squeeze(r.images{1});
ims = reshape(r.images{1},size(r.images{1},1)*size(r.images{1},2),size(r.images{1},3),size(r.images{1},4),size(r.images{1},5));
imNoise = squeeze(std(ims,[],1));
imMean = squeeze(mean(ims,1));
normIm = squeeze((ims(:,1,:,:)-200)./(ims(:,2,:,:)-200));
meanNormIm = squeeze(mean(normIm,1));
noiseNormIm = squeeze(std(normIm,[],1));
MeanOfMeans = mean(meanNormIm,2);
stdOfMeans = std(meanNormIm,[],2);
MeanNoise = mean(noiseNormIm,2);
StdNoise = std(noiseNormIm,[],2);
SNR = meanNormIm./noiseNormIm;
meanSNR = mean(SNR,2);
errorSNR = std(SNR,[],2);
figure;
yyaxis left
errorbar(p.loopVals{1},MeanOfMeans,stdOfMeans)
yyaxis right
errorbar(p.loopVals{1},MeanNoise,StdNoise)
figure;
errorbar(p.loopVals{1},meanSNR,errorSNR)
figure;
plot(p.loopVals{1},errorSNR./meanSNR)