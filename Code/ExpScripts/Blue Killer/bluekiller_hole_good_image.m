clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasTTresults = 0;
p.kdc = 1;
p.ttDumpMeasurement = 0;
p.hasPicturesResults=1;
p.picsPerStep = 1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.cameraParams{1}.B1BinningHorizontal='04';
p.cameraParams{1}.B2BinningVertical='04';
p.cameraParams{1}.ROI=[0, 0,1392/4, 1040/4];

initinst
initr
p.expName = 'Hole good image';
%% 
% inst.BiasFieldManager.I=[0.045   -0.0850    0.105]; %B field values to center MOT on camera
inst.BiasFieldManager.I=p.Blue_Killer_I;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.runStep;
p.flashTime=20;
p.runSettlingLoop=0;
p.MOTLoadTime=1.5e6;
p.NAverage=5;
p.BLUE_HOLE_Time = 1e3;
p.tofTime = 2e3;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({p.compoundActions.ReleaseMOT});

p.s.addBlock({'pause','duration',p.tofTime});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.coolingSwitch,'value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.repumpSwitch,'value','high','duration',p.BLUE_HOLE_Time});
p.s.addBlock({'pause','duration',p.BLUE_HOLE_Time});

p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
% p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ProbeSwitch,'value','high','duration',7});

p.s.addBlock({p.compoundActions.TakePicWithCooling})
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','low','duration',0});
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});


% for ii = 1:100
p.s.run();

% end



%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
yvals = (1:size(r.images{1},1))*14.7;
xvals = (1:size(r.images{1},2))*14.7;
figure;
imagesc(xvals*1e-3,yvals*1e-3,r.images{1}(:,:,1))
xlabel('x[mm]')
ylabel('y[mm]')
