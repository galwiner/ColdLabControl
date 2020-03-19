% 'TransientMagenticFieldCharechterization'

clear all
% profile clear
% profile on
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
p.coolingDet = -3*p.consts.Gamma;
p.PGCDetuning  = -10*p.consts.Gamma;
AOMcentFreq = 110;
span = abs(p.PGCDetuning-p.coolingDet)/2; %/2 because of double pass
center = AOMcentFreq-span/2;
p.PGCFreqRampTime = 100;
p.picsPerStep=2;
p.cameraParams{1}.E2ExposureTime = 50;
initinst
initr
inst.DDS.setupSweepMode(1,center,span,p.PGCFreqRampTime,1)
p.expName='TransientMagenticFieldCharechterization';

p.loopVars = {'settleTime'};
p.picsPerStep=2;

p.NAverage=5;
numSteps=15;
settleTimes = linspace(10,4e3,numSteps);
p.loopVals={settleTimes};
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.PGCTime = 10e3;
p.compressionTime = 50e3;
p.compressionEndCurrent = 220;
%Ploting params
p.plotingParams.legends={'MOT position','Position after 10 ms PGC'};
p.plotingParams.MaximizedWindow = 0;
p.plotingParams.NSubPlots = 1;
p.plotingParams.SupTitle = 'Cloud position after 10 ms PCG, vs settle time';
p.plotingParams.xaxis = {p.loopVals{1}*1e-3};
p.plotingParams.yaxes = {{r.fitParams{1}(4,1,1,:,:)},{r.fitParams{1}(4,2,1,:,:)}};
p.plotingParams.xlabel = {'Settle time [ms]'};
p.plotingParams.ylabels ={'Cloud z position'};

%%
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime-45e3,'EndCurrent',p.compressionEndCurrent});
p.s.addBlock({'pause','duration',p.compressionTime-40e3});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger photo'});%Trigger camera
p.s.addBlock({'pause','duration',40e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',p.settleTime})
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.PGCTime,'value','low','inverted','true'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime,'value','high'});
p.s.addBlock({'pause','duration',p.PGCTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'GenPause','channel','none','value','none','duration',0.5e6});
p.s.run;
%%
% imageViewer(r.images{1}(:,:,1,:))
% profile viewer
% profile off
figure;
hold on
time = p.loopVals{1}*1e-3;
avrgZpos = mean(squeeze(r.fitParams{1}(4,2,1,:,:)),2);
stdZpos = std(squeeze(r.fitParams{1}(4,2,1,:,:)),[],2);
errorbar(time,avrgZpos-9.8/2*(time'*1e-3).^2,stdZpos,'-o','LineWidth',2)
hold on
errorbar(time,mean(squeeze(r.fitParams{1}(4,1,1,:,:)),2),std(squeeze(r.fitParams{1}(4,2,1,:,:)),[],2),'-o','LineWidth',2)
xlabel('Settle time [ms]');
ylabel('MOT position after PGC');
set(gca,'FontSize',16)
% expPloter;