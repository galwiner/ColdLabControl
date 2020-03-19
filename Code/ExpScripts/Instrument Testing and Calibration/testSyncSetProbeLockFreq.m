clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=0;
p.hasSpecResults=1;
p.hasPicturesResults = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
p.benchtopSpecRes = 1;
initinst
initr

p.looping=1;
p.expName = 'testSyncSetProbeLockFreq';
%%
p.spectrumAnaParams{1}.centerFreq = 50;
p.spectrumAnaParams{1}.span = 90; 
p.stepTime = 1;
p.freqNum = 10;
p.probeRampTime = p.stepTime*p.freqNum;
p.probeRampSpan = 75;
p.probeLockCenter = probeDetToFreq(0,1);
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.probeRampSpan,p.probeRampTime,8,0,1e-1*p.freqNum,p.freqNum)

p.loopVals{1} = ((1:p.freqNum)-1)*p.stepTime;
p.loopVars{1} = 'freqJumpPause';
p.(p.loopVars{1}) = p.INNERLOOPVAR;

p.s=sqncr();
p.s.addBlock({'syncSetProbeLockFreq','freqJumpPause',p.freqJumpPause});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();
%%
freqs = r.specRes{1}(:,1,1,1);
setFreqs = linspace((p.probeLockCenter-p.probeRampSpan/2)/8,(p.probeLockCenter+p.probeRampSpan/2)/8,length(p.loopVals{1}));
for ii = 1:length(p.loopVals{1})
[pks(ii),inds(ii)] = findpeaks(r.specRes{1}(:,2,1,ii),'MinPeakProminence',50);

end
figure;
plot(setFreqs,freqs(inds),'o');
hold on;
f  = fit(setFreqs',freqs(inds),'poly1');
plot(f);
xlabel('set freq','fontsize',16)
ylabel('mess freq','fontsize',16);
txt1=sprintf('%0.2f*x+%0.2f',f.p1,f.p2);
yL=get(gca,'YLim'); 
xL=get(gca,'XLim');   
  text((xL(1)+xL(2))/2,0.9*yL(2),txt1,...
      'HorizontalAlignment','right',...
      'VerticalAlignment','top',...
      'BackgroundColor',[1 1 1],...
      'FontSize',16);