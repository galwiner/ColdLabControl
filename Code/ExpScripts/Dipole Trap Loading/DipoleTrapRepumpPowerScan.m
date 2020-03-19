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
p.postprocessing=1;
p.calcTemp = 0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{2}.B1BinningHorizontal = '01';
p.cameraParams{2}.B2BinningVertical = '01';
p.cameraParams{2}.ROI = [365,540,20,40];
p.cameraParams{1}.ROI = [760,520,100,100];
p.cameraParams{2}.E2ExposureTime = 1e3;
p.cameraParams{1}.E2ExposureTime = 1e3;
initinst
initr
p.expName = 'Dipole Trap Repump Power Scan';
%%

p.flashTime = 150;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
% p.repumpLoadingPower = 18;
p.coolingLoadingDeutuning = -30;
p.coolingLoadingPower = 30;
p.TrapTime = 40e3;
p.DTLoadTime = 10e3;
p.loopVals{1} = linspace(0.03,0.1,10); %Hold Time
p.loopVars{1} = 'repumpLoadingPower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;

% p.loopVals{2} = linspace(50,600,10); %Hold Time
% p.loopVars{2} = 'MOTReleaseTime';
% p.(p.loopVars{2}) = p.OUTERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.repumpLoadingPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.coolingLoadingDeutuning});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.coolingLoadingPower});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.DTLoadTime});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',p.TrapTime});
p.s.addBlock({'TakePic'});
p.looping = int16(1);
p.s.run();
if ~isempty(p.loopVals)
figure;plot(p.loopVals{1},squeeze(sum(sum(r.images{2},1),2)))
else
    imageViewer(r.images{2})
end




