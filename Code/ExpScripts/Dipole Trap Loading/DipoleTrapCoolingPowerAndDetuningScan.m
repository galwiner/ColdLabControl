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
p.cameraParams{2}.ROI = p.DipoleTrapROI{2};
p.cameraParams{1}.ROI = p.DipoleTrapROI{2};
p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
initinst
initr
p.expName = 'Dipole Trap Cooling Power And Detuning Scan';
%%
p.flashTime = 150;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
% p.repumpLoadingPower = 0.07;
% p.coolingLoadingDeutuning = -20;
% p.coolingLoadingPower = 50;
% p.TrapTime = 40e3;
% p.DTLoadTime = 30e3;
p.loopVals{1} = linspace(5,70,10); %Hold Time
p.loopVars{1} = 'DTParams.coolingLoadingPower';
p.DTParams.coolingLoadingPower = p.INNERLOOPVAR;
p.s=sqncr();
p.loopVals{2} = linspace(-40,-10,10); %Hold Time
p.loopVars{2} = 'DTParams.coolingLoadingDetuning';
p.DTParams.coolingLoadingDetuning = p.OUTERLOOPVAR;
% p.s.addBlock({'Load MOT'});
% p.s.addBlock({'setRepumpPower','duration',0,'value',p.repumpLoadingPower});
% p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.coolingLoadingDeutuning});
% p.s.addBlock({'setCoolingPower','duration',0,'value',p.coolingLoadingPower});
% p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
% p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
% p.s.addBlock({'pause','duration',p.DTLoadTime});
% p.s.addBlock({'Release MOT'});
% p.s.addBlock({'pause','duration',p.TrapTime});
% p.s.addBlock({'TakePic'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'TakePic'});
p.looping = int16(1);
p.s.run();
%%
atomNum = squeeze(sum(sum(r.images{2},1),2));
atomNum(atomNum==0) = nan;
atomNum = atomNum - 200*size(r.images{2},1)*size(r.images{2},2);
atomNum = getAtomNum(atomNum,'top');
if ~isempty(p.loopVals)
    if length(p.loopVals)==1
        figure;
        plot(p.loopVals{1},atomNum)
    else
        if length(p.loopVals{1})==1
            figure;
            plot(p.loopVals{2},atomNum)
        elseif length(p.loopVals{2})==1
            figure;
            plot(p.loopVals{1},atomNum)
        else
            figure;
            imagesc(p.loopVals{1},p.loopVals{2},atomNum)
        end
    end
else
    imageViewer(r.images{2})
end
    
    
    
    
