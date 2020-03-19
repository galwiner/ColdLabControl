clear all;
global p;
global r;
global inst;
initp
p.idsLiveMode = 0;
p.pfLiveMode = 0;
p.flashTime = 10;
p.picsPerStep = 1;
p.cameraParams{1}.E2ExposureTime = 1e3;
p.cameraParams{2}.E2ExposureTime = 1e3;

p.expName = 'idsQuantumEffMes';
initinst
initr
%%
p.imagingBeamPower = 75; %in muW
p.imagingPower = 35;
p.AbsImgTime = 100;
p.s = sqncr;
% p.s.addBlock({'setDigitalChannel','channel','imagingTTL','value','high','duration',0});
p.s.addBlock({'pause','duration',1e6});
p.s.addBlock({'TakeAbsPic'});
p.s.run;
imageViewer(r.images{2})
%%
bgIm = r.images{2}(1:100,1:100);
bg = mean(bgIm(:));
im = r.images{2}(210:780,460:1050);
totalCounts = sum(im(:))-size(im,1)*size(im,2)*bg;
photonEnergy = 2*pi*p.consts.hbar*p.consts.c/780.24e-9; %in J
photonNumber = p.imagingBeamPower*1e-6*p.AbsImgTime*1e-6/photonEnergy;
qe = totalCounts/photonNumber*100