clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.NTOF = 10;
p.expName='Dipole Trap Thermometary';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=p.NTOF;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.calcTemp = 1;
p.cameraParams{1}.B1BinningHorizontal = '04';
p.cameraParams{1}.B2BinningVertical = '04';
p.cameraParams{1}.ROI  =round(p.cameraParams{1}.ROI/4);
% p.cameraParams{2}.B1BinningHorizontal = '04';
% p.cameraParams{2}.B2BinningVertical = '04';
% p.cameraParams{2}.ROI = round(p.cameraParams{2}.ROI/4);

% p.cameraParams{1}.B1BinningHorizontal = '01';
% p.cameraParams{1}.B2BinningVertical = '01';
% p.cameraParams{2}.B1BinningHorizontal = '01';
% p.cameraParams{2}.B2BinningVertical = '01';
p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{2}.E2ExposureTime=1e3;
p.DEBUG=DEBUG;
%
p.FunctionGen = 0;
% p.HHXCurrent = -0.046;
% p.HHYCurrent = -0.0733;
initinst
initr

%%
p.flashTime = 200;
p.DTParams.LoadingTime = 1e5;
% p.DTParams.TrapTime = 4e4-2e3;
p.DTParams.TrapTime = 1;
p.DTParams.repumpLoadingPower = 0.057;
p.DTParams.coolingLoadingPower = 30;
p.DTParams.coolingLoadingDetuning = -35;
% p.DTParams.LoadingTime =  15e4;
% p.TOFtimes = [2,3,4,5,6,7]*1e3;
p.TOFtimes = linspace(1,5,p.NTOF)*1e3;
p.s = sqncr;
p.s.addBlock({'pause','duration',2e4})
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','high','duration',0});
p.s.addBlock({'pause','duration',2e4})
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','low','duration',0});
p.s.addBlock({'pause','duration',6e4})
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'endOfSeqToF'})
p.s.run

imageViewer(r.images{1}(:,:,:))
%
ycut = squeeze(r.images{1}(:,161,:,:,:,:));
% meanycut = squeeze(mean(ycut,6));
% scale = inst.cameras('pixelflyPlane').getScale;
scale =4*4.0994e-06;
%[Amp,cent,sigma,bg]
initparams = [4500,2.6e-3,1e-4,250];
x=(1:size(ycut,1))*scale;
for ii=1:size(ycut,2)
%     for ii=1:1
     figure;
    if ii~=1
      initparams = fitParams(:,ii-1);
    end
    [fitobject,fitParams(:,ii),fitFunc,gof,output] = fit1DGaussian(x,ycut(:,ii),initparams);
        plot(x,ycut(:,ii))
        hold on
        plot(fitobject)
end
figure;
plot((p.TOFtimes+100).^2,fitParams(3,:).^2)
delayList = p.TOFtimes*1e-6+100e-6;
[Tfit,TGOF]=fit(delayList'.^2,fitParams(3,:)'.^2,'poly1');
mrb=p.consts.mrb;
kb=p.consts.kb;
T=1e6.*Tfit.p1*mrb/kb;
