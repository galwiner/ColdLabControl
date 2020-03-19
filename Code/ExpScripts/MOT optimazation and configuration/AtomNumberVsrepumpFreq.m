clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='atom number vs repump freq';
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
p.loopVars{1} = 'repumpDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.loopVals{1} = linspace(-2*p.consts.Gamma,1*p.consts.Gamma,20);

p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'}) 
p.s.addBlock({'TakePic'});
p.looping = int16(1);
p.s.run();

% imageViewer(r.images{1});
%%
% atomNum = squeeze(r.atomNum{1});
% figure;
% plot(p.loopVals{1},atomNum,'o','markersize',8)
% dets = linspace(-5,5,200);
% f1=fitLorentzian(atomNum,p.loopVals{1}',[max(atomNum),0,2,0],[1e2,inf]);
% hold on
% plot(dets,f1(dets),'linewidth',2);
% legend('data','fit','Location','northwest');
% xlabel('Repump Freq [MHz]');
% ylabel('Atom Number');
% set(gca,'FontSize',16)
% title('Atom number (repump detuning)')
% text(-12,2e8,sprintf('Center = %.2f MHz',f1.b))
% text(-12,1.5e8,sprintf('HWHM = %.2f MHz',f1.c))
% legend off

atomNum = squeeze(r.atomNum{1});
normPwers = p.loopVals{1}'/max(p.loopVals{1});
figure;
plot(normPwers,atomNum,'o','markersize',8)
initParams = [3e8,3/18];
[fitobj,gof,output] = fitTransitionSaturation(normPwers,atomNum,initParams);
hold on;
pwers = ExpandVecForFit(normPwers,100);
plot(pwers,fitobj(pwers),'linewidth',2);
xlabel('Repump Power [normalized]');
ylabel('Atom Number')
legend('data','fit')
% text(
