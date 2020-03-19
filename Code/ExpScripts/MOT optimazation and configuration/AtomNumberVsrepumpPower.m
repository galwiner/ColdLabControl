clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='atom number vs repump power';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.calcTemp = 0;
p.cameraParams{1}.B1BinningHorizontal = '04';
p.cameraParams{1}.B2BinningVertical = '04';
p.cameraParams{1}.ROI = [100,75,200,225-75];
p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{2}.E2ExposureTime=1e3;
p.DEBUG=DEBUG;
%
initinst
initr


%%
p.flashTime = 20;
p.MOTLoadTime = 4e6; 
% p.repumpPower = 18;
p.loopVars{1} = 'repumpPower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.loopVals{1} = linspace(1,18,20);


p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'}) 
p.s.addBlock({'TakePic'});
p.looping = int16(1);
p.s.run();

% imageViewer(r.images{1});
%%
aromNum = squeeze(r.atomNum{1});
figure;
plot(p.loopVals{1},aromNum,'o','markersize',8)
pwrs = linspace(min(p.loopVals{1}),max(p.loopVals{1}),200);
%A*x/x0/(1+x/x0)
initParams = [3e8,6];
[fitobj,gof,output] = fitTransitionSaturation(p.loopVals{1}',aromNum,initParams);
hold on
plot(pwrs,fitobj(pwrs),'linewidth',2);
legend('data','fit','Location','northwest');
xlabel('Repump Power [mW]');
ylabel('Atom Number');
set(gca,'FontSize',16)



