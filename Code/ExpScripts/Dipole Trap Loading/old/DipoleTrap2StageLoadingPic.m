clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp

p.expName='DipoleTrap2StageLoadingPic';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp = 0;
p.DEBUG=DEBUG;

p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{1}.ROI  =round(p.cameraParams{1}.ROI);
p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{2}.E2ExposureTime=1e3;
p.flashTime = 50;
initinst
initr
%%
%1st stage params
p.DTParams.LoadingTime = 1e5;
p.MOTReleaseTime = 300;
p.DTParams.TrapTime = 6e4;
p.DTParams.repumpLoadingPower = 0.057;
p.DTParams.coolingLoadingPower = 55;
p.DTParams.coolingLoadingDetuning = -20;
p.DTParams.MOTLoadTime = 2e6;
%2nd Stage params

p.secondStageCoolingDet = -75;
p.secondStageCoolingPower = 350;
p.secondStageRepumpPower = 0.05;
p.secondStageTime = 20e3;


%setup params
p.coolingDet = p.DTParams.coolingDet;
p.circCurrent = p.DTParams.circCurrent;
p.MOTLoadTime = p.DTParams.MOTLoadTime;
p.coolingDet = p.DTParams.coolingDet;
p.circCurrent = p.DTParams.circCurrent;

%sequence
p.s = sqncr;
%Turn off control and probe
p.s.addBlock({'pause','duration',2e4})
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','high','duration',0});
p.s.addBlock({'pause','duration',2e4})

p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','duration',0,'value','low'});
%1st stage loading
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.DTParams.repumpLoadingPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.DTParams.coolingLoadingDetuning});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.DTParams.coolingLoadingPower});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.DTParams.LoadingTime});
%2nd stage loading
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.secondStageCoolingDet});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.secondStageCoolingPower});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.secondStageRepumpPower});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.secondStageTime})
%turn off mot and trap
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setAnalogChannel','channel','CircCoil','duration',0,'value',0});
p.s.addBlock({'pause','duration',100});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','low','duration',0});
p.s.addBlock({'pause','duration',6e4})
p.s.addBlock({'pause','duration',p.DTParams.TrapTime-6e4});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
%realse trap and tof
p.s.addBlock({'TakePic'});
p.s.run
%%
imageViewer(r.images{1}(:,:,:))
%
ycut = squeeze(r.images{1}(:,646,:,:,:,:));
% meanycut = squeeze(mean(ycut,6));
% scale = inst.cameras('pixelflyPlane').getScale;
scale =4.0994e-06;
%[Amp,cent,sigma,bg]
initparams = [10000,2.6e-3,1e-4,250];
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
