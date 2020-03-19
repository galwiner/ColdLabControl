%cooling power sweep with fast mode spectroscopy
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep = 1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=0;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{2}.B1BinningHorizontal = '01';
p.cameraParams{2}.B2BinningVertical = '01';
% p.cameraParams{2}.ROI = [1,540,20,40];
p.cameraParams{1}.ROI = [640,690,60,50];
p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
initinst
initr
p.expName = 'Dipole Trap Cooling And Repump Power';
%%
p.flashTime = 250;
p.DTParams.LoadingTime = 2e5;
p.loopVals{1} = linspace(0.04,0.06,10);
p.loopVars{1} = 'repumpLoadingPower';
p.DTParams.repumpLoadingPower = p.INNERLOOPVAR;

p.loopVals{2} = linspace(50,50,1);
p.loopVars{2} = 'coolingLoadingPower';
p.DTParams.coolingLoadingPower = p.OUTERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','low'});
p.s.addBlock({'pause','duration',4e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',2e4});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','duration',0,'value','high'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',1e5});
p.looping = int16(1);
p.s.run();
   imageViewer(r.images{1}) 
%%
if ~isempty(p.loopVals)
    if length(p.loopVals)==1
        figure;
        plot(p.loopVals{1},squeeze(sum(sum(r.images{2},1),2)))
    else
        if length(p.loopVals{1})==1
            figure;
            plot(p.loopVals{2},squeeze(sum(sum(r.images{2},1),2)))
        elseif length(p.loopVals{2})==1
            figure;
            plot(p.loopVals{1},squeeze(sum(sum(r.images{2},1),2)))
        else
            figure;
            imagesc(p.loopVals{1},p.loopVals{2},squeeze(sum(sum(r.images{2},1),2)))
        end
    end
else
    imageViewer(r.images{2})
end
    
    
    
