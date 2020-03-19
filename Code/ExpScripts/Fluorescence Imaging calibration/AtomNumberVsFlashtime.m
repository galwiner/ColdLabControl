clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Atom Number vs Flash time';
p.hasScopResults=1;
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
p.NAverage = 1;
initinst
initr
%%  
p.MOTLoadTime = 8e6;
% p.s=sqncr();
% p.s.addBlock({'Load MOT'});
% p.s.runStep();
% p.MOTReloadTime = 1e6;
p.loopVals{1} =linspace(100,1000,25);
p.loopVars{1} = 'flashTime';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.flashTime = 5;
p.s=sqncr();
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',0.5e3});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',p.MOTReloadTime})
p.s.run();
%
integNum = sum(reshape(r.images{1},[size(r.images{1},1)*size(r.images{1},2),size(r.images{1},3),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6)]),1)-size(r.images{1},1)*size(r.images{1},2)*200;
atomNum_fromInt = getAtomNum(integNum(:));
atomNum_fromInt =squeeze(reshape(atomNum_fromInt,size(integNum)));
figure;

if p.NAverage>1
meanAtomNum = mean(squeeze(r.atomNum{1}),2);
errorAtomNum = std(squeeze(r.atomNum{1}),[],2);
meanAtomNum_fromInt = mean(squeeze(atomNum_fromInt),2);
errorAtomNum_fromInt = std(squeeze(atomNum_fromInt),[],2);

errorbar(p.loopVals{1},meanAtomNum,errorAtomNum,'LineWidth',2);
hold on
errorbar(p.loopVals{1},meanAtomNum_fromInt,errorAtomNum_fromInt,'LineWidth',2);
xlabel('Flash Time [\mus]')
ylabel('Atom Number');
legend('Fit Method','Integration Method')
title('Atom # vs Florescence Flash Time, in a dilute MOT')
else
plot(p.loopVals{1},squeeze(r.atomNum{1}),'-o','LineWidth',2);
hold on
plot(p.loopVals{1},atomNum_fromInt,'-o','LineWidth',2);   
xlabel('Flash Time [\mus]')
ylabel('Atom Number');
title('Atom # vs Florescence Flash Time, in a dilute MOT')
legend('Fit Method','Integration Method')
set(gca,'FontSize',16)
figure;
plot(p.loopVals{1},squeeze(r.atomDensity{1}),'-o','LineWidth',2);
xlabel('Flash Time [\mus]')
ylabel('Atom Density');
legend('Fit Method','Integration Method')
set(gca,'FontSize',16)
end