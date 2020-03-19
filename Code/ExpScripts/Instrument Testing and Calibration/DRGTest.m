clear all
global p

global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.hasSpecResults = 1;
p.benchtopSpecRes = 1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.numberOfSteps = 100;
p.SweepSpan = 100; %corresponsd to 1 MHz steps
p.SweepTime = 1*p.numberOfSteps; %corresponsd to 1 mus between steps
p.centerFreq = 100;
p.spectrumAnaParams{1}.centerFreq = p.centerFreq;
p.spectrumAnaParams{1}.span = p.SweepSpan+10;
p.spectrumAnaParams{1}.BW = 30e3;
p.spectrumAnaParams{1}.refAmp = 10;
p.NAverage = 1;
initinst
initr
%loop params
p.numSteps = 99;
p.loopVars{1}='HoldOffTime';
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.loopVals{1} = 0.5+0:p.numSteps;
p.expName='DRGTest';
inst.DDS.setupSweepMode(2,p.centerFreq,p.SweepSpan,p.SweepTime,1,1,[],p.numberOfSteps);
%%
p.s=sqncr();
%inittialize the DDS to low
p.s.addBlock({'setDigitalChannel','channel','DDS2_HLD','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.SweepTime*1.5});
p.s.addBlock({'setDigitalChannel','channel','DDS2_HLD','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.SweepTime*1.5});
p.s.addBlock({'TrigScope'});
% p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','DDS2_HLD','duration',p.HoldOffTime,'value','low','inverted','true'});
p.s.addBlock({'pause','duration',p.SweepTime*1.5});
% p.s.addBlock({'forEnd','value',p.forLoopNum});
% p.s.addBlock({'forEnd','value',2});
p.s.run();

%%
figure;
plot(r.specRes{1}(:,1),squeeze(r.specRes{1}(:,2,:)))
% legend(sprintf('%d pulses',p.loopVals{1}(1)),sprintf('%d pulses',p.loopVals{1}(2)),sprintf('%d pulses',p.loopVals{1}(3)))
% xlim([50 70])
% set(gca,'FontSize',16);
% averagedparams=mean(squeeze(r.fitParams{1}),3);
% figure;plot(CoolingResonanseFreqs./p.consts.Gamma,squeeze(averagedparams(2,:,:,:)),'o-');
