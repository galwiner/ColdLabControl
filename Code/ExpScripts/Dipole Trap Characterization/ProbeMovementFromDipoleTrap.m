clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='ProbeMovementFromDipoleTrap';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=1;
p.idsLiveMode=0;
p.idsMonitor = 1;
p.postprocessing=0;
p.calcTemp = 0;
% p.cameraParams{1}.B1BinningHorizontal = '01';
% p.cameraParams{1}.B2BinningVertical = '01';
% p.cameraParams{2}.B1BinningHorizontal = '04';
% p.cameraParams{2}.B2BinningVertical = '04';
% p.cameraParams{2}.ROI = round(p.cameraParams{2}.ROI/4);

% p.cameraParams{1}.B1BinningHorizontal = '01';
% p.cameraParams{1}.B2BinningVertical = '01';
% p.cameraParams{2}.B1BinningHorizontal = '01';
% p.cameraParams{2}.B2BinningVertical = '01';
% p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{2}.E2ExposureTime=1e3;
p.DEBUG=DEBUG;
%
p.FunctionGen = 0;
% p.HHXCurrent = -0.046;
% p.HHYCurrent = -0.0733;
initinst
initr

%%
p.flashTime = 100;
p.NAverage = 3;
p.repumpTime = 100;
p.loopVals{1} = linspace(-50,50,1);
p.loopVars{1} = 'probeDet';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s = sqncr;
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.repumpTime});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTopTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'pause','duration',5.6});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',p.flashTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0,'description','picture: set repump to resonanse'});
p.s.addBlock({'setRepumpPower','duration',0,'value',18,'description','Load MOT: set repump power'});
p.s.addBlock({'GenPause','duration',2*p.cameraParams{2}.E2ExposureTime});
% p.s.addBlock({'TakePic'})
p.s.run;
% im = mean(squeeze(r.images{2}),3);
% imageViewer(im)
%%
meanIm = squeeze(mean(r.images{2},6));
figure
while 1
    for ii = 1:length(p.loopVals{1})
        imagesc(meanIm(:,:,ii))
        title(sprintf('detuning = %0.2d MHz',p.loopVals{1}(ii)))
        colorbar
%         hold on
%         contour(fit_img,'r')
%         hold off
        pause(0.1)
    end
    waitforbuttonpress
end
        
