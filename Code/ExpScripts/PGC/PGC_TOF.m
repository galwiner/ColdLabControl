
clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
p.hasPicturesResults=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.DEBUG=DEBUG;
p.coolingDet = -3*p.consts.Gamma;
p.PGCDetuning  = -14*p.consts.Gamma;
AOMcentFreq = 110;
span = abs(p.PGCDetuning-p.coolingDet)/2; %/2 because of double pass
center = AOMcentFreq-span/2;
p.PGCFreqRampTime = 100;
p.calcTemp=1;
p.NTOF=4;
p.picsPerStep=p.NTOF;
p.cameraParams{1}.E2ExposureTime = 50;
p.expName='PGC Thermometry';
p.SingleTOFTime = 20e3;
p.TOFtimes = [0,p.SingleTOFTime];
p.settleTime = 1e3;
p.loopVars = {'PGCTime'};

numSteps=10;

p.TOFtimes=linspace(1e2,10e3,p.NTOF);
PGCTimeVals=linspace(50,1e3,numSteps);

initinst
initr
p.s.getbgImg();
p.NAverage=1;
p.loopVals={PGCTimeVals};
p.(p.loopVars{1})=p.INNERLOOPVAR;
inst.DDS.setupSweepMode(1,center,span,p.PGCFreqRampTime,1)
p.HoldTime = 6e3;

%%

%%
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.HoldTime,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.HoldTime,'value','high'});
p.s.addBlock({'pause','duration',p.HoldTime});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',p.settleTime})
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.PGCTime,'value','low','inverted','true','description','PGC: DDS CTRL'});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',p.PGCFreqRampTime,'EndPower',880});
% p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',100,'description','Load MOT: set cooling power'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',p.PGCTime,'value','high','description','PGC: Cooling ON'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',p.PGCTime,'value','high','description','PGC: Repump ON'});
p.s.addBlock({'pause','duration',p.PGCTime,'description','PGC: pause during PGC'});
p.s.addBlock({'endOfSeqToF'});
% p.s.addBlock({'GenPause','channel','none','value','none','duration',0.5e6});
p.s.run;
%%
figure;
subplot(2,1,1)
averageTx = mean(squeeze(r.Tx{1}),3);
errorTx = std(squeeze(r.Tx{1}),[],3);
averageTy = mean(squeeze(r.Ty{1}),3);
errorTy = std(squeeze(r.Ty{1}),[],3);
errorbar(PGCTimeVals/1e3,averageTx,errorTx,'-ob','LineWidth',2);
hold on
errorbar(PGCTimeVals/1e3,averageTy,errorTy,'-or','LineWidth',2);

ylabel('Temp [\mu K]');
xlabel('PGC Time [ms]');
title('-10 \Gamma PGC');
legend('Tx','Ty');
set(gca,'FontSize',22)
subplot(2,1,2)
avrageAtomNum = mean(squeeze(r.atomNum{1}(1,1,:,:)),3);
errorAtomNum = std(squeeze(r.atomNum{1}(1,1,:,:)),[],3);
avrageAtomdensity = mean(squeeze(r.atomDensity{1}(1,1,:,:)),3);
errorAtomdensity = std(squeeze(r.atomDensity{1}(1,1,:,:)),[],3);

yyaxis left
errorbar(PGCTimeVals,avrageAtomNum,errorAtomNum,'-ob','LineWidth',2)
ylabel('Atom Number')
yyaxis right
errorbar(PGCTimeVals,avrageAtomdensity,errorAtomdensity,'-or','LineWidth',2)
ylabel('Atom density [cm^{-3}]')
xlabel('PGC time [\mus]');
set(gca,'FontSize',22)
% yyaxis left
% errorbar(PGCTimeVals,mean(squeeze(r.fitParams{1}(3,2,1,:,:)),2),std(squeeze(r.fitParams{1}(3,2,1,:,:)),[],2));
% hold on
% errorbar(PGCTimeVals,mean(squeeze(r.fitParams{1}(4,2,1,:,:)),2),std(squeeze(r.fitParams{1}(4,2,1,:,:)),[],2));
% yyaxis right
% errorbar(PGCTimeVals,mean(squeeze(r.fitParams{1}(7,2,1,:,:)),2),std(squeeze(r.fitParams{1}(7,2,1,:,:)),[],2));
% errorbar(PGCTimeVals,mean(squeeze(r.fitParams{1}(6,2,1,:,:)),2),std(squeeze(r.fitParams{1}(6,2,1,:,:)),[],2));
% figure;imagesc(r.images{1}(:,:,2,1,1,1))
% figure;imagesc(r.images{1}(:,:,1,1,1,1))