clear all
global p
global r
global inst
DEBUG=0;
initp
p.expName='Gravitometry';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{1}.E2ExposureTime=150;
p.cameraParams{2}.E2ExposureTime=30;
p.DEBUG=DEBUG;
initinst
initr
%%  
p.MOTLoadTime = 8e6;
p.loopVals{1} = linspace(1e3,20e3,15);
p.loopVars{1} = 'TOFTime';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.MOTLoadTime = 4e6;
p.HoldTime = 6e3;
p.TrapTime = 40e3;
p.PGCDetuning = -80;
p.PGCPower = 100;
p.PGCTime = 3e3;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.HoldTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.HoldTime,'value','high'});
p.s.addBlock({'pause','duration',p.HoldTime});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime,'value','high'});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.PGCDetuning});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.PGCPower,'description','Load MOT: set cooling power'});
p.s.addBlock({'pause','duration',p.PGCTime});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',p.TOFTime});
p.s.addBlock({'TakePic'});
p.looping = int16(1);
p.s.run();
%%
zVals = r.fitParams{1}(4,:);
time = p.loopVals{1}*1e-6; %in sec
startVals = [-9.8,0.0045];
ffun=fittype('a/2*x^2+b');
options=fitoptions(ffun);
options.StartPoint=startVals;
[cfun,gof]=fit(time',-zVals',ffun,options);
g = cfun.a;
figure;
plot(time,-zVals,'o')
hold on;
plot(time,cfun(time),'LineWidth',2)
xlabel('time [s]');
ylabel('cloud position [m]');
title(sprintf('Gravitometry, g = %0.2f [m/s^2]',g))
set(gca,'FontSize',16)