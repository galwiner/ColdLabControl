%fast mode spectroscopy on a cold cloud, in live camera mode
clear all
global p

global r
global inst
DEBUG=0;
initp
% p.AbsImgTime = 200;
p.cameraParams{1}.E2ExposureTime = p.AbsImgTime;
p.hasScopResults=0;
p.hasPicturesResults=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.picsPerStep = 2;
initinst
initr
p.expName = 'Take Absotption image';
p.PGCDetuning  = -16*p.consts.Gamma;
AOMcentFreq = 110;
span = abs(p.PGCDetuning-p.coolingDet)/2; %/2 because of double pass
center = AOMcentFreq-span/2;
p.PGCFreqRampTime = 100;
p.PGCTime = 40e3;
inst.DDS.setupSweepMode(1,center,span,p.PGCFreqRampTime,1);
p.PGCEndCoolingPower = 400;

%%
p.s=sqncr();
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'TakeAbsPic'});
% p.s.addBlock({'Load MOT'});
% p.s.addBlock({'Release MOT'});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'GenPause','duration',1e3});
p.looping = int16(1);
p.s.run();

figure;
% imagesc(r.images{1}(:,:,1))
imagesc(r.images{1}(:,:,1)-r.images{1}(:,:,2));
% imagesc(r.images{1}(:,:,2))
figure;plot(im(:,166),'o-')
figure;imagesc(-log(r.images{1}(:,:,2)./r.images{1}(:,:,1))); %OD

