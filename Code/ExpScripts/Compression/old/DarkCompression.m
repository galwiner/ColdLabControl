clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Dark Compression';
p.coolingDet = -3*p.consts.Gamma;


p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.calcTemp = 0;
p.cameraParams{1}.E2ExposureTime=20;
p.compressionTime = 50e3;
p.DEBUG=DEBUG;
%Scan setup
p.PGCDetuning  = p.INNERLOOPVAR;
Nsteps = 10;
p.NAverage=1;
spanVals = (-3-linspace(-16,-5,Nsteps))*p.consts.Gamma/2;
UpFreq = 110;
DownFreqVals = UpFreq-spanVals;
DownFreq = p.INNERLOOPVAR;
p.loopVals ={DownFreqVals};
p.loopVars = {'DownFreq'};
%
initinst
initr
p.compressionRampTime = 20e3; %in us
p.compressionEndCurrent=220;
p.MOTLoadTime = 3e6;

%%

p.s=sqncr();
p.s.addBlock({'SetupDDSSweepUpDown','channel',1,'UpFreq',UpFreq,'DownFreq',DownFreq,'symmetric',0,'UpTime',50,'downTime',p.compressionRampTime});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionRampTime,'EndCurrent',p.compressionEndCurrent});
p.s.addBlock({'setDigitalChannel','channel','DDS1_CTL','duration',p.compressionTime,'value','low','inverted','true'});
p.s.addBlock({'pause','duration',50e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'TakePic'});
p.looping = int16(1);
p.s.run();

%%
% imageViewer(r.images{1});
figure;
subplot(2,2,1);
p.finalCompressionDetunings=-(spanVals*2+3*p.consts.Gamma);
errorbar(p.finalCompressionDetunings,mean(squeeze(r.atomNum{1}),2),std(squeeze(r.atomNum{1}),[],2),'o-','LineWidth',2)
xlabel('Compression final detuning [MHz]');
ylabel('Atom number');
set(gca,'FontSize',22);
xlim([min(p.finalCompressionDetunings)-1 max(p.finalCompressionDetunings)+1])
subplot(2,2,2);
errorbar(p.finalCompressionDetunings,mean(squeeze(r.fitParams{1}(5,1,1,:,:)),2),std(squeeze(r.fitParams{1}(5,1,1,:,:)),[],2),'o-','LineWidth',2);
hold on
errorbar(p.finalCompressionDetunings,mean(squeeze(r.fitParams{1}(6,1,1,:,:)),2),std(squeeze(r.fitParams{1}(6,1,1,:,:)),[],2),'o-','LineWidth',2)
xlabel('Compression final detuning [MHz]');
ylabel('cloud width [m]');
legend({'\sigma_x','\sigma_y'})
set(gca,'FontSize',22);
xlim([min(p.finalCompressionDetunings)-1 max(p.finalCompressionDetunings)+1])
subplot(2,2,[3,4]);
errorbar(p.finalCompressionDetunings,mean(squeeze(r.atomDensity{1}),2),std(squeeze(r.atomDensity{1}),[],2),'o-','LineWidth',2)
xlabel('Compression final detuning [MHz]');
ylabel('Atom density');

xlim([min(p.finalCompressionDetunings)-1 max(p.finalCompressionDetunings)+1])
% suptitle('Compression detuning scan',22)
set(gca,'FontSize',22);