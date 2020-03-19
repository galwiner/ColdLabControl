clear all
global p

global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
p.hasPicturesResults=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.DEBUG=DEBUG;
p.cameraParams{1}.E2ExposureTime = 1e3;
p.flashTime = 10;
p.cameraParams{1}.B1BinningHorizontal = '04';
p.cameraParams{1}.B2BinningVertical = '04';
p.cameraParams{1}.ROI = p.cameraParams{1}.ROI/4;
initinst
initr
p.expName = 'cooling detuning and current sweep';

p.loopVars = {'coolingDet','circCurrent'};
coolingDetVals=linspace(-6,-2,10)*p.consts.Gamma;
circCurrentVals = linspace(10,60,10);
p.loopVals={coolingDetVals,circCurrentVals};
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.(p.loopVars{2})=p.OUTERLOOPVAR;
p.MOTLoadTime = 2e6;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'TakePic'});
p.looping = int16(1);
p.s.run();
%%
r.atomNum{1} = squeeze(r.atomNum{1});
r.atomDensity{1} = squeeze(r.atomDensity{1});
dets = p.loopVals{1}/p.consts.Gamma;
figure;
% subplot(2,1,1)
% grads = AHHCurrent2Grad(p.loopVals{2});
imagesc(dets,p.loopVals{2},squeeze(r.atomNum{1}))
% title('Atom number')
% xlabel('Cooling power [mW]')
% ylabel('\nablaB [gauss\\cm]') 
% set(gca,'FontSize',22)
% subplot(2,1,2)
% imagesc(p.loopVals{1},grads,squeeze(r.atomDensity{1}))
% xlabel('Cooling power [mW]')
% ylabel('\nablaB [gauss\\cm]') 
% title('Atom density')
% set(gca,'FontSize',22)
% figure;
% hold on
% for ii = 1:length(p.loopVals{2})
% %     if ii~=1
% %         plot(p.loopVals{2},r.atomNum{1}(ii,:)+max(r.atomNum{1}(ii-1,:)))
% %     else
%         plot(p.loopVals{1},r.atomNum{1}(ii,:),'LineWidth',2);
% %     end
% end
% xlim([min(p.loopVals{1}) max(p.loopVals{1})]);
% xlabel('Cooling power [mW]')
% ylabel('Atom Number (not accurate)') 
% set(gca,'FontSize',16)