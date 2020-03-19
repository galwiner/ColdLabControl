%This experiment tests the bias boils 

clear all
imaqreset
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
p.picsPerStep=2;
p.pfPlaneLiveMode=0;
p.pfTopLiveMode=0;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.expName = 'resonant flesh';
p.cameraParams{1}.E2ExposureTime = 200;
p.cameraParams{2}.E2ExposureTime = 200;
initinst
initr
p.s.getbgImg;
%% setup seq

p.SettleTime = 1e3;
p.tofTime=4e3;
p.flashTime = 30;
p.flashPower = 15;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','trigger ICE jump'});
p.s.addBlock({'pause','duration',p.SettleTime});
p.s.addBlock({'pause','duration',p.flashTime});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTopTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'pause','duration',max(p.cameraParams{1}.E2ExposureTime,p.cameraParams{2}.E2ExposureTime)});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','trigger ICE jump'});

p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','trigger ICE jump'});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',100,'EndPower',p.flashPower});
p.s.addBlock({'pause','duration',p.SettleTime});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.flashTime,'value','high'});
p.s.addBlock({'pause','duration',p.flashTime});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',100,'EndPower',p.coolingPower});
p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTopTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'pause','duration',max(p.cameraParams{1}.E2ExposureTime,p.cameraParams{2}.E2ExposureTime)});
p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','trigger ICE jump'});

p.looping = int16(1);
p.s.run();
% Ploting
figure;
subplot(2,2,1)
imagesc(r.images{1}(:,:,1))
colorbar
subplot(2,2,2)
imagesc(r.images{2}(:,:,1)-r.bgImg{2})
colorbar
subplot(2,2,3)
imagesc(r.images{1}(:,:,2))
colorbar
subplot(2,2,4)
imagesc(r.images{2}(:,:,2)-r.bgImg{2})
colorbar
figure
subplot(2,2,1)
plot(sum(r.images{1}(:,:,1)-r.bgImg{1},1)./max(sum(r.images{1}(:,:,1)-r.bgImg{1},1)))
hold on
plot(sum(r.images{1}(:,:,2)-r.bgImg{1},1)./max(sum(r.images{1}(:,:,2)-r.bgImg{1},1)))
title('Plane pixelfly x profile (y axis)')
legend('Without Flash','With Flash')
subplot(2,2,2)
plot(sum(r.images{1}(:,:,1)-r.bgImg{1},2)./max(sum(r.images{1}(:,:,1)-r.bgImg{1},2)))
hold on
plot(sum(r.images{1}(:,:,2)-r.bgImg{1},2)./max(sum(r.images{1}(:,:,2)-r.bgImg{1},2)))
title('Plane pixelfly y profile (z axis)')
legend('Without Flash','With Flash')
subplot(2,2,3)
plot(sum(r.images{2}(:,:,1)-r.bgImg{2},1)./max(sum(r.images{2}(:,:,1)-r.bgImg{2},1)))
hold on
plot(sum(r.images{2}(:,:,2)-r.bgImg{2},1)./max(sum(r.images{2}(:,:,2)-r.bgImg{2},1)))
title('Top pixelfly x profile (x axis)')
legend('Without Flash','With Flash')
subplot(2,2,4)
plot(sum(r.images{2}(:,:,1)-r.bgImg{2},2)./max(sum(r.images{2}(:,:,1)-r.bgImg{2},2)))
hold on
plot(sum(r.images{2}(:,:,2)-r.bgImg{2},2)./max(sum(r.images{2}(:,:,2)-r.bgImg{2},2)))
title('Top pixelfly y profile (y axis)')
legend('Without Flash','With Flash')