clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='compression repump detuning and repump power scan';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.absImg{1}=0;
p.picsPerStep=2;
p.pfPlaneLiveMode=0;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.calcTemp = 0;
p.cameraParams{1}.B1BinningHorizontal = '04';
p.cameraParams{1}.B2BinningVertical = '04';
p.cameraParams{1}.ROI = (p.cameraParams{1}.ROI)/4; %start x, start y, width x, width y
p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{2}.E2ExposureTime=1e3;
p.imagingPower = 200;
p.AbsImgTime = 10;
p.flashTime = p.AbsImgTime;
p.DEBUG=DEBUG;
%
initinst
initr


%%
p.MOTReloadTime = 1.5e6;
p.GaussianFitThreshold = 0.7;
p.flashTime = 20;
p.NAverage = 1;
p.DTPic = 0;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
p.repumpDetuning = 0;
p.FinalCircCoil = 220;
p.compressionDelay = 8e3;
p.MOTLoadTime = 8e6;
% p.s=sqncr();
% p.s.addBlock({'Load MOT'});
% p.s.runStep;
p.s=sqncr();
p.s.addBlock({'Release MOT'});
p.s.addBlock({'Reload MOT'});
p.s.runStep;
p.expansionTime = 3e3;
p.compRepumpDetuning = 5.5;
p.compressionPower = 690;
p.compressionDetuning = -15;
% p.loopVars{1} = 'compressionDetuning';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.loopVals{1} = linspace(-15,-15,1);
% p.loopVars{2} = 'compressionPower';
% p.(p.loopVars{2}) = p.OUTERLOOPVAR;
% p.loopVals{2} = linspace(100,400,10);
p.loopVars{1} = 'compRepumpDetuning';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.loopVals{1} = linspace(0,5.5,10);
p.loopVars{2} = 'compRepumpPower';
p.(p.loopVars{2}) = p.OUTERLOOPVAR;
p.loopVals{2} = linspace(18,18,1);
p.s=sqncr();
% p.s.addBlock({'Load MOT'});
%first image, with high density, for size
p.s.addBlock({'setCircCurrent','channel','CircCoil','duration',0,'value',p.FinalCircCoil});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.compressionPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.compressionDetuning});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',p.compRepumpDetuning});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.compRepumpPower});
p.s.addBlock({'pause','duration',p.compressionDelay});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'});
%secend image, with low density, for atom number
p.s.addBlock({'setCircCurrent','channel','CircCoil','duration',0,'value',p.FinalCircCoil});
p.s.addBlock({'setCoolingPower','duration',0,'value',p.compressionPower});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',p.compressionDetuning});
p.s.addBlock({'setRepumpDetuning','duration',0,'value',p.compRepumpDetuning});
p.s.addBlock({'setRepumpPower','duration',0,'value',p.compRepumpPower});
p.s.addBlock({'pause','duration',p.compressionDelay});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',p.expansionTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
p.looping = int16(1);
p.s.run();


%%
% r.atomNum{1}(:,:,end) = [];
% p.loopVals{1}(end) = [];
% r.atomDensity{1}(:,:,end) = [];
% r.fitParams{1}(:,:,:,end) = [];
if length(p.loopVals)==1
    p.loopVals{2} = 0;
end
if length(p.loopVals{2})>1 && length(p.loopVals{1})>1
    figure;
    subplot(2,2,1)
    imagesc(p.loopVals{1},p.loopVals{2},squeeze(r.atomNum{1}(1,:,:)));
    colorbar
    subplot(2,2,2)
    imagesc(p.loopVals{1},p.loopVals{2},squeeze(r.atomNum{1}(2,:,:)));
    colorbar
    subplot(2,2,3)
    imagesc(p.loopVals{1},p.loopVals{2},squeeze(r.atomDensity{1}(1,:,:)));
    colorbar
    atomNumvec = squeeze(r.atomNum{1}(2,:));
    sigmaVec = squeeze([r.fitParams{1}(5,1,:);r.fitParams{1}(6,1,:)]);
    reconDensity = getAtomDensity(atomNumvec,sigmaVec);
    reconDensity = squeeze(reshape(reconDensity,size(r.atomNum{1},2),size(r.atomNum{1},3)));
    subplot(2,2,4)
    imagesc(p.loopVals{1},p.loopVals{2},squeeze(reconDensity));
    colorbar
else
    if length(p.loopVals{2})==1
        figure;
        subplot(2,1,1)
        plot(p.loopVals{1},squeeze(r.atomNum{1}(1,:,:)));
        hold on
        plot(p.loopVals{1},squeeze(r.atomNum{1}(2,:,:)));
        subplot(2,1,2)
        plot(p.loopVals{1},squeeze(r.atomDensity{1}(1,:,:)));
        hold on
        atomNumvec = squeeze(r.atomNum{1}(2,:));
        sigmaVec = squeeze([r.fitParams{1}(5,1,:);r.fitParams{1}(6,1,:)]);
        reconDensity = getAtomDensity(atomNumvec,sigmaVec);
        reconDensity = squeeze(reshape(reconDensity,size(r.atomNum{1},2),size(r.atomNum{1},3)));
        plot(p.loopVals{1},squeeze(reconDensity));
    else
        figure;
        subplot(3,1,1)
        plot(p.loopVals{2},squeeze(r.atomNum{1}(1,:,:)));
        hold on
        plot(p.loopVals{2},squeeze(r.atomNum{1}(2,:,:)));
        subplot(3,1,2)
        plot(p.loopVals{2},squeeze(r.atomDensity{1}(1,:,:)));
        hold on
        atomNumvec = squeeze(r.atomNum{1}(2,:));
        sigmaVec = squeeze([r.fitParams{1}(5,1,:);r.fitParams{1}(6,1,:)]);
        reconDensity = getAtomDensity(atomNumvec,sigmaVec);
        reconDensity = squeeze(reshape(reconDensity,size(r.atomNum{1},2),size(r.atomNum{1},3)));
        plot(p.loopVals{2},squeeze(reconDensity));
        subplot(3,1,3)
        plot(p.loopVals{2},squeeze(r.fitParams{1}(5,1,:)));
        hold on
        plot(p.loopVals{2},squeeze(r.fitParams{1}(6,1,:)));
    end
end