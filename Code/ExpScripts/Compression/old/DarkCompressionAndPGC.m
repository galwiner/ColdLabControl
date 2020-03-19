clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Dark Compression and PGC';
p.coolingDet = -3*p.consts.Gamma;
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=4;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.calcTemp = 1;
p.cameraParams{1}.E2ExposureTime=20;

p.DEBUG=DEBUG;

%
initinst
initr
p.MOTLoadTime = 8e6;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.runStep();
p.compressionEndCurrent=220;


%%
p.MOTReloadTime = 2000e3;
p.PGCTime = 5e3;

p.compressionTime = 130e3;
p.compressionRampTime = 100e3;
% p. = 20e3; %in us
%Scan setup
% p.PGCDetuning  = p.INNERLOOPVAR;
p.DDSRampTime = p.compressionRampTime*10/6;
% Nsteps = 10;
% PGCTimeVals = linspace(15e3,45e3,Nsteps);
% compressionRampTimeVals = linspace(80e3,p.compressionTime-20e3,Nsteps);
% p.compressionRampTime=p.INNERLOOPVAR;
% p.PGCTime = p.INNERLOOPVAR;
% p.loopVals{1} = PGCTimeVals;
% p.loopVars{1} = 'PGCTime';
p.NAverage=1;
% spanVals = (-3-linspace(-12,-3.5,Nsteps))*p.consts.Gamma/2;
UpFreq = 110;
DownFreq = UpFreq - (-3+10)*p.consts.Gamma/2;
p.PGCEndCoolingPower = 400;
% DownFreqVals = UpFreq-spanVals;
% DownFreq = p.INNERLOOPVAR;
% p.loopVals ={DownFreqVals};
% p.loopVars = {'DownFreq'};
p.s=sqncr();
p.s.addBlock({'SetupDDSSweepUpDown','channel',1,'UpFreq',UpFreq,'DownFreq',DownFreq,'symmetric',0,'UpTime',50,'downTime',p.compressionRampTime});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionRampTime,'EndCurrent',p.compressionEndCurrent});
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.compressionRampTime});
p.s.addBlock({'setDigitalChannel','channel','DDS1_HLD','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.compressionTime-p.compressionRampTime});
%start PGC
p.s.addBlock({'setDigitalChannel','channel','DDS1_HLD','duration',0,'value','low'});
p.s.addBlock({'startCoolingPowerRamp','channel','COOLVVAN','value','none','duration',10e3,'EndPower',p.PGCEndCoolingPower});
p.s.addBlock({'pause','duration',p.PGCTime});
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',0,'value','high'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',880});
% p.s.addBlock({'TakePic'});
% p.s.addBlock({'Reload MOT'});
% p.s.addBlock({'GenPause','duration',p.MOTReloadTime});
p.s.addBlock({'endOfSeqToF'});
p.looping = int16(1);
p.s.run();

%
%  imageViewer(r.images{1});
% figure;
% plot(p.loopVals{1}/1e3,r.Tx{1});
% hold on
% plot(p.loopVals{1}/1e3,r.Ty{1});
% legend('Tx','Ty')
% figure;
% subplot(2,2,1);
% errorbar(p.loopVals{1}*1e-3,mean(squeeze(r.atomNum{1}),2),std(squeeze(r.atomNum{1}),[],2),'o-','LineWidth',2)
% xlabel('Compression ramp time [ms]');
% ylabel('Atom number');
% set(gca,'FontSize',22);
% % xlim([min(p.finalCompressionDetunings)-1 max(p.finalCompressionDetunings)+1])
% subplot(2,2,2);
% errorbar(p.loopVals{1}*1e-3,mean(squeeze(r.fitParams{1}(5,1,1,:,:)),2),std(squeeze(r.fitParams{1}(5,1,1,:,:)),[],2),'o-','LineWidth',2);
% hold on
% errorbar(p.loopVals{1}*1e-3,mean(squeeze(r.fitParams{1}(6,1,1,:,:)),2),std(squeeze(r.fitParams{1}(6,1,1,:,:)),[],2),'o-','LineWidth',2)
% xlabel('Compression ramp time [ms]');
% ylabel('cloud width [m]');
% legend({'\sigma_x','\sigma_y'})
% set(gca,'FontSize',22);
% % xlim([min(p.finalCompressionDetunings)-1 max(p.finalCompressionDetunings)+1])
% subplot(2,2,[3,4]);
% errorbar(p.loopVals{1}*1e-3,mean(squeeze(r.atomDensity{1}),2),std(squeeze(r.atomDensity{1}),[],2),'o-','LineWidth',2)
% xlabel('Compression ramp time [ms]');
% ylabel('Atom density');
% 
% % xlim([min(p.finalCompressionDetunings)-1 max(p.finalCompressionDetunings)+1])
% % suptitle('Compression detuning scan',22)
% set(gca,'FontSize',22);


% figure;
% subplot(2,2,1);
% p.finalCompressionDetunings=-(spanVals*2+3*p.consts.Gamma);
% errorbar(p.finalCompressionDetunings,mean(squeeze(r.atomNum{1}),2),std(squeeze(r.atomNum{1}),[],2),'o-','LineWidth',2)
% xlabel('Compression final detuning [MHz]');
% ylabel('Atom number');
% set(gca,'FontSize',22);
% xlim([min(p.finalCompressionDetunings)-1 max(p.finalCompressionDetunings)+1])
% subplot(2,2,2);
% errorbar(p.finalCompressionDetunings,mean(squeeze(r.fitParams{1}(5,1,1,:,:)),2),std(squeeze(r.fitParams{1}(5,1,1,:,:)),[],2),'o-','LineWidth',2);
% hold on
% errorbar(p.finalCompressionDetunings,mean(squeeze(r.fitParams{1}(6,1,1,:,:)),2),std(squeeze(r.fitParams{1}(6,1,1,:,:)),[],2),'o-','LineWidth',2)
% xlabel('Compression final detuning [MHz]');
% ylabel('cloud width [m]');
% legend({'\sigma_x','\sigma_y'})
% set(gca,'FontSize',22);
% xlim([min(p.finalCompressionDetunings)-1 max(p.finalCompressionDetunings)+1])
% subplot(2,2,[3,4]);
% errorbar(p.finalCompressionDetunings,mean(squeeze(r.atomDensity{1}),2),std(squeeze(r.atomDensity{1}),[],2),'o-','LineWidth',2)
% xlabel('Compression final detuning [MHz]');
% ylabel('Atom density');
% 
% xlim([min(p.finalCompressionDetunings)-1 max(p.finalCompressionDetunings)+1])
% % suptitle('Compression detuning scan',22)
% set(gca,'FontSize',22);