
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
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
p.looping=1;
p.expName = 'Probe Alignement On Dipole Trap';
cam = idsCam('monitor');
expTime = 1e3;
cam.setExposure(expTime);
cam.setHWTrig;
cam.startRingBufferMode(1);
flashTime = 300;
p.flashTime = flashTime;
%%
% p.DTParams.repumpLoadingPower = 0.06;
p.DTParams.TrapTime = 2e4;
for ind_cyc=1:1
% p.MOTReleaseTime = 300;
% p.DTParams.TrapTime = 4e4;
% p.s=sqncr();
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'});
% p.s.addBlock({'LoadDipoleTrap'});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
% % p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'});
% % p.s.addBlock({'pause','duration',0.5e3})
% % p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'});
% p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High'})
% p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.flashPower});
% p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
% p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',flashTime,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',flashTime,'value','high'});
% p.s.addBlock({'pause','duration',expTime})
% p.s.addBlock({'GenPause','duration',1e5});
% % p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',p.probeRampTime*2.5,'value','high'});
% % p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',p.probeRampTime+50,'value','high'});
% % p.s.addBlock({'pause','duration',p.probeRampTime*2.5});
% % p.s.addBlock({'pause','duration',4.1e3});
% p.s.run();
% im = cam.getBufferImages;
% im_no_control = im(600:800,660:860);
for ii = 1:1
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','low'});
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});

% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'});
% p.s.addBlock({'pause','duration',0.5e3})
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'});
% p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High'})
% p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.flashPower});
% p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
% p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
% p.s.addBlock({'setRepumpPower','duration',0,'value',18});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',flashTime,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',flashTime,'value','high'});
% p.s.addBlock({'pause','duration',expTime})
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',1e4})
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','high'});
p.s.addBlock({'GenPause','duration',1e5});
p.s.run();
im(:,:,ii) = cam.getBufferImages;
end
imageViewer(r.images{1}(620:760,500:800))
% imageViewer(r.images{1})
hold on;
plot(p.probePosInPixelfly(1)-500,p.probePosInPixelfly(2)-620,'xr')
% plot(p.probePosInPixelfly(1),p.probePosInPixelfly(2),'xr')
figure;
imagesc(im(330:400,640:720))
% imagesc(im)

% im_yes_control = im(600:800,660:860);
% 
% imf_no_control=imgaussfilt(im_no_control,4);
% imf_yes_control=imgaussfilt(im_yes_control,4);
% subplot(2,2,1);imagesc(imf_no_control);
% subplot(2,2,2);imagesc(imf_yes_control);
% subplot(2,2,3);imagesc(imf_no_control-imf_yes_control);
% plot(r.scopeRes{1});
end