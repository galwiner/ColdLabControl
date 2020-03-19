% 'magnetic trapping for bias compensation'

clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.DEBUG=DEBUG;
p.coolingDet = -5.5*p.consts.Gamma;
p.cameraParams{1}.E2ExposureTime = 900;
% p.cameraParams{2}.exposure = 700;
p.HHYCurrent = p.INNERLOOPVAR; %in A. 
p.HHZCurrent = -0.0889; %in A
p.HHXCurrent = -0.010; %in A 

p.circCurrent=40;

p.expName='magnetic trapping for bias compensation';
numSteps = 10;
p.loopVals = {linspace(-015,-0.03,numSteps)};
p.loopVars = {'HHYCurrent'};
% p.loopVars = {'settleTime'};
p.picsPerStep=2;
% numSteps=10;
p.NAverage=1;
p.HHZVoltageLimit=20;
% settleTimes = linspace(10,1e3,numSteps);
% p.loopVals={settleTimes};
% p.(p.loopVars{1})=p.INNERLOOPVAR;
p.magneticTrapSettleTime=80e3;
p.compressionTime = 5e3;
p.FirstcompressionEndCurrent = 220;
p.SecondcompressionEndCurrent = 130;
initinst
initr
%%
p.s.getbgImg;
p.s=sqncr();
p.s.addBlock({'setHH','direction','y','value',p.HHYCurrent})
p.s.addBlock({'Load MOT'});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',p.FirstcompressionEndCurrent});
p.s.addBlock({'pause','duration',50e3});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low','description','cooling beam off'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','repump beam off'});
p.s.addBlock({'pause','duration',p.magneticTrapSettleTime});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',2e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',2e3});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',p.SecondcompressionEndCurrent});
p.s.addBlock({'pause','duration',50e3});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low','description','cooling beam off'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','repump beam off'});
p.s.addBlock({'pause','duration',p.magneticTrapSettleTime});
% p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',2e3});
p.s.addBlock({'Release MOT'});
p.s.run;
%%
figure
plot(p.loopVals{1},squeeze(r.fitParams{1}(4,1,:)),'bo');
hold on
plot(p.loopVals{1},squeeze(r.fitParams{1}(4,2,:)),'ko');
legend('Z position at 220 A','Z position at 130 A')
figure
plot(p.loopVals{1},squeeze(r.fitParams{1}(3,1,:)),'ro');
hold on
plot(p.loopVals{1},squeeze(r.fitParams{1}(3,2,:)),'mo');
legend('Y position at 220 A','Y position at 130 A')
%%
imageViewer(squeeze(r.images{1}(:,:,2,:))-r.bgImg{1})
