clear all
imaqreset
global p
global r
global inst
DEBUG=0;
initp
p.hasTTresults = 0;
p.ttDumpMeasurement = 0;
p.absImagePostproc=1;
p.hasPicturesResults=1;
p.pfLiveMode=0;
p.hasScopResults = 0;
% p.HHZCurrent=0.04;
% p.HHXCurrent=-0.035;
% p.HHYCurrent=-0.0744;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{1}.ROI = p.DipoleTrapROI{1};
p.picsPerStep=2;
initinst
initr
p.expName = 'OD vs loading time with abs imaging';

%%

%set y bias field, and zeeman powers
% for ii = 1:100
p.runSettlingLoop = 0;
p.ZeemanNDList = [11,7];
p.zeemanRepumpND=[1];
p.zeemanPumpPower = 1e-3;
p.zeemanRepumpPower = 1.5e-3;
p.s = sqncr;
p.s.addBlock({p.asyncActions.setZeemanPumpPower,'value',p.zeemanPumpPower,'ND',p.ZeemanNDList});
p.s.addBlock({p.asyncActions.setZeemanRepumpPower,'value',p.zeemanRepumpPower,'ND',p.zeemanRepumpND});
p.s.runStep;

p.NAverage = 4;
p.AbsImgTime = 10;
%optical pumping settings and probe power
p.BiasField=-0.5;
p.probeNDList = [13,3,2];

p.MagneticPulseTime=15e3;
p.repumpTime = 100;
%dipole trap loading params
% p.DTParams.MOTLoadTime = 0.25e6;
p.DTParams.TrapTime = 1;
% p.DTParams.LoadingTime = 1;
% p.DTParams.secondStageTime = 1;
% loop params
p.loopVals{1} = linspace(0.1,1,10)*1e6;
% p.loopVals{1} = 0.25e6;
p.loopVars{1} = 'DTParams.MOTLoadTime';
p.DTParams.MOTLoadTime = p.INNERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'configDoubleBPulse','firstB',[0,0,1]})
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','high'}); %turn on 480 AOM 
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','low'}); %close 480 shutter 
p.s.addBlock({p.compoundActions.LoadDipoleTrapAndPump});
% p.s.addBlock({p.compoundActions.LoadDipoleTrap});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','duration',0,'value','high'}); %open 480 shutter 
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'}); %turn off 480 AOM 
p.s.addBlock({'pause','duration',5e3}); %additional trapping time
%measure
p.s.addBlock({p.compoundActions.TakeAbsPic});
% p.s.addBlock({p.compoundActions.TakePic});
%measure without atoms
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({p.atomicActions.pause,'duration',200e3});
p.s.addBlock({p.compoundActions.TakeAbsPic});
% p.s.addBlock({p.compoundActions.TakePic});
p.s.addBlock({p.atomicActions.pause,'duration',5e3});
%reset
p.s.addBlock({p.compoundActions.resetSystem});
p.s.run;


% normIm =squeeze((r.images{1}(:,:,1)-200)./(r.images{1}(:,:,2)-200));
% figure;
% imagesc(normIm)
% caxis([0 1])
% figure;
% plot(normIm(88,:));
% hold on;
% plot(normIm(:,94))
% hold off;

% end
% 
% p.s=sqncr();
% p.s.addBlock({'configDoubleBPulse'})
% p.s.run()
