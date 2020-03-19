clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Atom Number vs TOF time';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
if p.picsPerStep == 1
    p.calcTemp = 0;
else
    p.calcTemp = 1;
end
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{1}.ROI = [550,400,400,400];
p.NAverage = 5;
initinst
initr
%%  
p.MOTLoadTime = 8e6;
p.flashTime = 50;
% p.s=sqncr();
% p.s.addBlock({'Load MOT'});
% p.s.runStep();
p.MOTReloadTime = 1e6;
p.loopVals{1} =linspace(100,400,20);
p.loopVars{1} = 'TofTime';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',0.5e3});
p.s.addBlock({'pause','duration',p.TofTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime})
p.s.run();
%%
integNum = sum(reshape(squeeze(r.images{1}),size(r.images{1},1)*size(r.images{1},2),size(r.images{1},5),size(r.images{1},6)),1)-size(r.images{1},1)*size(r.images{1},2)*200;
atomNum_fromInt = getAtomNum(integNum);
meanAtomNum = mean(squeeze(r.atomNum{1}),2);
errorAtomNum = std(squeeze(r.atomNum{1}),[],2);
meanAtomNum_fromInt = mean(squeeze(atomNum_fromInt),2);
errorAtomNum_fromInt = std(squeeze(atomNum_fromInt),[],2);
figure;
% yyaxis left
errorbar(p.loopVals{1}+p.flashTime/2,meanAtomNum,errorAtomNum);
hold on
% yyaxis right
errorbar(p.loopVals{1}+p.flashTime/2,meanAtomNum_fromInt,errorAtomNum_fromInt);
% imageViewer(r.images{1})

