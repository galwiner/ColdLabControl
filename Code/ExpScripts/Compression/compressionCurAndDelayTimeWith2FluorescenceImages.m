clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='compression current and delay time scan with two fluorescence images';
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
p.GaussianFitThreshold = 0.5;
p.flashTime = 20;
p.NAverage = 1;
p.DTPic = 0;
p.coolingDet = -4*p.consts.Gamma;
p.circCurrent = 20;
p.repumpDetuning = 0;
% p.FinalCircCoil = 220;
p.compressionDelay = 15;
p.MOTLoadTime = 8e6;
% p.s=sqncr();
% p.s.addBlock({'Load MOT'});
% p.s.runStep;
p.s=sqncr();
p.s.addBlock({'Release MOT'});
p.s.addBlock({'Reload MOT'});
p.s.runStep;
p.expansionTime = 3e3;
% p.loopVars{1} = 'expansionTime';
% p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.loopVals{1} = linspace(0.5e3,5e3,15);
p.loopVars{2} = 'FinalCircCoil';
p.(p.loopVars{2}) = p.INNERLOOPVAR;
p.loopVals{2} = linspace(220,220,1);
p.loopVars{1} = 'compressionDelay';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.loopVals{1} = linspace(1,15,15)*1e3;
p.MOTReloadTime = 1.5e6;
p.s=sqncr();
% p.s.addBlock({'Load MOT'});
%first image, with high density, for size
p.s.addBlock({'setCircCurrent','channel','CircCoil','duration',0,'value',p.FinalCircCoil});
p.s.addBlock({'pause','duration',p.compressionDelay});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'});
%secend image, with low density, for atom number
p.s.addBlock({'setCircCurrent','channel','CircCoil','duration',0,'value',p.FinalCircCoil});
p.s.addBlock({'pause','duration',p.compressionDelay});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',p.expansionTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'});
p.looping = int16(1);
p.s.run();


%%
meanAtomNum = mean(r.atomNum{1},4);
atomNumError = std(r.atomNum{1},[],4);
figure;
errorbar(p.loopVals{1},meanAtomNum(2,:),atomNumError(2,:),'-o')
hold on;
errorbar(p.loopVals{1},meanAtomNum(1,:),atomNumError(1,:),'-o')

meanDensity = mean(r.atomDensity{1},4);
densityError = std(r.atomDensity{1},[],4);
figure;
% errorbar(p.loopVals{1},meanDensity(2,:),densityError(2,:),'-o')
errorbar(p.loopVals{1},meanDensity(1,:),densityError(1,:),'-o')
hold on;
atomNumvec = squeeze(r.atomNum{1}(2,:));
sigmaVec = squeeze([r.fitParams{1}(5,1,1,:);r.fitParams{1}(6,1,1,:)]);
raconDensity = getAtomDensity(atomNumvec,sigmaVec);
raconDensity = reshape(raconDensity,size(r.atomNum{1},3),size(r.atomNum{1},4));
meanRaconDensity = mean(raconDensity,2);
RaconDensityError = std(raconDensity,[],2);
errorbar(p.loopVals{1},meanRaconDensity,RaconDensityError,'-o')
