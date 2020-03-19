%cooling power sweep with fast mode spectroscopy
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep = 1;
p.pfLiveMode=0;
p.postprocessing=0;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{2}.B1BinningHorizontal = '01';
p.cameraParams{2}.B2BinningVertical = '01';
p.cameraParams{1}.E2ExposureTime = 10e6;
initinst
initr
p.expName = 'ImageProbeOnPixelfly';

%%
p.probeNDList = [0];
% p.loopVals{1} = linspace(0.5,1.8,4);
% p.loopVars{1} = 'probePower';
% p.probePower = p.INNERLOOPVAR;
p.probePower = 1.8;

r.images{1} = [];
p.NAverage = 10;
p.s = sqncr;
p.s.addBlock({p.atomicActions.setProbePower,'duration',0,'value',p.probePower})
p.s.addBlock({p.atomicActions.setDigitalChannel,'duration',0,'value',1,'channel',p.chanNames.ProbeSwitch})
p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High'});
p.s.addBlock({'pause','duration',p.cameraParams{1}.E2ExposureTime});
p.s.run;
%%
figure;
tiledlayout('flow')
if isempty(p.loopVals)
    p.loopVals{1} = 1;
end
for ii = 1:length(p.loopVals{1})
nexttile
tmpIm = mean(squeeze(r.images{1}(:,:,1,1,ii,:)),3);
imagesc(tmpIm)
caxis([0.3*tmpIm(60,670) 1.2*tmpIm(60,670)])
end
benedIm  = biny(tmpIm,10);
% [Amp,cent,sigma,bg]
fos = {};
params = zeros(4,size(benedIm,1));
for ii = 1:size(benedIm,1)
ip = [benedIm(ii,670)-benedIm(ii,1),680,100,benedIm(ii,1)];
[fos{end+1},params(:,ii)] = fit1DGaussian(1:size(benedIm,2),benedIm(ii,:)',ip);
end
% figure;
% tiledlayout('flow')
% 
% for ii = 1:size(benedIm,1)
% nexttile
% plot(benedIm(ii,:))
% hold on;
% plot(fos{ii})
% end
