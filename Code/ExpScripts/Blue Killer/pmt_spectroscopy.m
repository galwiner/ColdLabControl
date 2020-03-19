clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasTTresults = 0;
p.ttDumpMeasurement = 0;
p.hasPicturesResults=0;
p.hasScopResults=1;

% p.pfLiveMode=0;
% p.tcLiveMode=1;
% p.idsMonitor = 1;

% p.cameraParams{1}.B1BinningHorizontal='04';
% p.cameraParams{1}.B2BinningVertical='04';
% p.cameraParams{1}.ROI=[180, 120,50, 50];
p.chanList=[1];
initinst
initr
p.expName = 'PMT spectroscopy';
p.runSettlingLoop=0;
inst.BiasFieldManager.I=[0.0500   -0.0895    0.100];
% inst.DDS.setFreq(1,390);
 
% p.cameraParams{1}
p.loopVals={};
p.loopVars = {};
p.MOTLoadTime=1;

p.s=sqncr();
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'pause','duration',1e5});
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.coolingSwitch,'value','high','duration',0})
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.repumpSwitch,'value','high','duration',0})
p.s.run
t0Ind = 2*find(r.scopeDigRes{1}(:,2)==1,1)+10;
r.PMT_BG=mean(squeeze(r.scopeRes{1}(t0Ind:end,2,:,:)),1);
p.MOTLoadTime=2.5e6;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.atomicActions.pause,'duration',0.5e5});
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();
t0Ind = 2*find(r.scopeDigRes{1}(:,2)==1,1)+10;
r.PMT_fully_loaded_mot=r.scopeRes{1}(t0Ind:end,2,1);

%%


p.NAverage=1;
p.nInner = 40;
vals= linspace(RydbergDet2synthHDFreq(250),RydbergDet2synthHDFreq(270),p.nInner);
startPt=1;
p.loopVals{1}=vals(startPt:end);
p.loopVars{1} = 'TS_Detuning';
p.(p.loopVars{1})=p.INNERLOOPVAR;


resetControlLock(p.loopVals{1}(1));
p.s=sqncr();
p.s.addBlock({p.asyncActions.setSynthHDFreq,'channel','A','freq',p.TS_Detuning});
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({'setDigitalChannel','channel','CTRL480Shutter','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({p.atomicActions.pause,'duration',0.5e5});
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run();



%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
%%
t0Ind = 2*find(r.scopeDigRes{1}(:,2,1)==1,1)+10;
r.MOT_loading=squeeze(r.scopeRes{1}(t0Ind:end,2,:));
r.time=squeeze(r.scopeRes{1}(t0Ind:end,1,1));
ip = [1,1];
fos = {};
r2 = zeros(1,p.nInner);
fcoef = zeros(2,p.nInner);
for ii = 1:p.nInner
    [fos{end+1},gof] = fitMOTLoading(r.time,r.MOT_loading(:,ii)-r.PMT_BG,ip);
    r2(ii) = gof.rsquare;
    fcoef(:,ii) = coeffvalues(fos{end});
end
% fcoef(:,4) = nan(2,1);
% figure;
% imagesc(r.MOT_loading-r.PMT_BG)
r.BadMeas = [22,23];
fcoef(:,r.BadMeas) = nan(2,length(r.BadMeas));
    [fos_mot,gof_mot] = fitMOTLoading(r.time,r.PMT_fully_loaded_mot-r.PMT_BG,ip);
    r2_mot = gof_mot.rsquare;
    fcoef_mot = coeffvalues(fos_mot);
figure;
subplot(3,1,1)
plot(synthHDFreq2RydbergDet(p.loopVals{1}),fcoef(1,:)/fcoef_mot(1),'-o');
title('N/N_{full}')
xlabel('Detuning [MHz]')
subplot(3,1,2)
plot(synthHDFreq2RydbergDet(p.loopVals{1}),fcoef(1,:)./fcoef(2,:)/(fcoef_mot(1)/fcoef_mot(2)),'-o');
xlabel('Detuning [MHz]')
title('Loading rate with blue light over MOT loading rate')
subplot(3,1,3)
plot(synthHDFreq2RydbergDet(p.loopVals{1}),1./fcoef(2,:),'-o');
hold on
plot(synthHDFreq2RydbergDet(p.loopVals{1}),1./fcoef_mot(2)*ones(size(p.loopVals{1})),'--k');
title('Decay Rate [s^{-1}]')
xlabel('Detuning [MHz]')
legend('With blue light','Regular MOT')
ylim([1./fcoef_mot(2)*0.5,max(1./fcoef(2,:))*1.1])
% figure;
% r.pmtReadings=mean(squeeze(r.scopeRes{1}(:,2,:,:)),1);
% plot(synthHDFreq2RydbergDet(p.loopVals{1}),(r.pmtReadings-r.PMT_BG)/(r.PMT_fully_loaded_mot-r.PMT_BG))
% xlabel('Blue Detuning [MHz]')
% ylabel('N/N_{full}')

