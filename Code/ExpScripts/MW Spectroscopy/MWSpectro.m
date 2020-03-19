
clear all
global p

global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.picsPerStep = 1;
p.cameraParams{1}.E2ExposureTime = 200;
initinst
initr
p.s = sqncr;

p.hasPicturesResults=1;
p.pfLiveMode=0;
p.tcLiveMode=0;
r.bgscope = r.scopeRes{1};
p.expName = 'Microwave Spectroscopy';
% scp = keysightScope('10.10.10.118','MOTSCOPE','ip');
numSteps = 15;
MWPulseTimes=linspace(50,350,numSteps);
p.loopVals={MWPulseTimes};
p.loopVars = {'MWPulseTime'};
p.(p.loopVars{1})=p.INNERLOOPVAR;

%%
% p.MWPulseTime = 560;
% p.s.getbgImg;
% scp.setState('single');
p.MOTReleaseTime = 400;
p.flashTime = 200;
imagePause = max(p.cameraParams{1}.E2ExposureTime,p.cameraParams{2}.E2ExposureTime);
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'})
%turn on cooling (pump population to F=1)
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.flashTime,'value','high','description','MW spectro:cooling laser on'});
%pause for flash time
p.s.addBlock({'pause','duration',p.flashTime});
%flash with MW
p.s.addBlock({'setDigitalChannel','channel','MWSourceSwitch','value','high','duration',p.MWPulseTime});
p.s.addBlock({'pause','duration',p.MWPulseTime});
%2nd flash
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTopTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',imagePause,'value','high','description','MW spectro:cooling laser on'});
p.s.addBlock({'pause','duration',imagePause});
% p.s.addBlock({'TakePicForMWSpectro'});
p.looping = int16(1);
p.s.run();

%%
bgres = mean(r.bgscope(:,3));
% bgres = 0;
initParams = [810,0,0.15,0.06,1500];
lower = [700,-pi,0.01,0.02,1000];
upper = [1000,pi,0.2,0.07,50000];
transferEfficiency = squeeze(max(r.scopeRes{1}(:,3,:),[],1))-bgres;
[fitobject,gof,output] = fitRabiOscilations(p.loopVals{1},transferEfficiency,initParams,lower,upper);
time = linspace(p.loopVals{1}(1),p.loopVals{1}(end),300);
figure;
plot(p.loopVals{1},transferEfficiency,'LineWidth',2)
hold on
plot(time,fitobject(time))
title('MW Rabi oscillations');
xlabel('MW Pulse Time [\mus]')
ylabel('Normalized Max PMT signal');
set(gca,'FontSize',16)
xlim([min(p.loopVals{1}) max(p.loopVals{1})]);
disp(fitobject)