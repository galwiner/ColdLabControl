
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
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
p.looping=1;
% p.expName = 'Control Alignement On Dipole Trap';
cam = idsCam;
expTime = 1e3;
cam.setExposure(expTime);
cam.setHWTrig;
cam.startRingBufferMode(1);
flashTime = 300;
%%
% f1=figure;
% ax1=gca;
f2=figure;
ax2=gca;

for ind=1:100
p.MOTReleaseTime = 300;
p.DTParams.TrapTime = 4e4;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High'})
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.flashPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',flashTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',flashTime,'value','high'});
p.s.addBlock({'pause','duration',expTime})
p.s.addBlock({'GenPause','duration',1e5});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',p.probeRampTime*2.5,'value','high'});
% p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',p.probeRampTime+50,'value','high'});
% p.s.addBlock({'pause','duration',p.probeRampTime*2.5});
% p.s.addBlock({'pause','duration',4.1e3});
p.s.run();

im = cam.getBufferImages;
% % figure(f1)
% subplot(3,3,[3,6])
% plot(f1,im(608:750,1002),1:143)
% title('y')
% subplot(3,3,[7,8])
% plot(f1,im(695,920:1100))
% title('x')
% subplot(3,3,[1,2,4,5])
% imagesc(im(608:750,920:1100))
% figure(f2)
imagesc(im)
% subplot(2

end
% im2 = im(560:820,560:900);
% figure;

% plot(r.scopeRes{1});
% figure;
% plot(ax,im2(:,177))