clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Atom Number vs Imaging Flash Power';
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
p.cameraParams{1}.E2ExposureTime=50;
p.cameraParams{1}.ROI = [550,450,400,300];
p.NAverage = 10;
initinst
initr
%%  
p.MOTLoadTime = 8e6;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.runStep();
p.loopVals{1} =linspace(50,1000,15);
p.loopVars{1} = 'flashPower';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.pauseBetweenImages = 200e3;
p.s=sqncr();
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime})
p.s.run();
%%
meanAtomNum = mean(squeeze(r.atomNum{1}),2);
bgIm = squeeze(r.images{1}(1:50,350:400,1,1,1,1));
bg = mean(bgIm(:));
AtomNum_sum = sum(reshape(r.images{1},size(r.images{1},1)*size(r.images{1},2),size(r.images{1},5),size(r.images{1},6)),1);
AtomNum_sum = squeeze(AtomNum_sum)-size(r.images{1},1)*size(r.images{1},2)*bg;
meanAtomNum_sum = mean(AtomNum_sum,2);
meanAtomNum_sum = getAtomNum(meanAtomNum_sum);
meanDensity = mean(squeeze(r.atomDensity{1}),2);
figure;
yyaxis left
plot(p.loopVals{1},meanAtomNum)
hold on
plot(p.loopVals{1},meanAtomNum_sum)
yyaxis right
plot(p.loopVals{1},meanDensity)

