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
p.hasPicturesResults=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.DEBUG=DEBUG;
initinst
initr
p.expName='MOTFlashResonanceSearch';
p.loopVars = {'resonantImagingDetuning'};
p.picsPerStep=1;
numSteps=1;
p.NAverage=1;
% CoolingResonanseFreqs=linspace(coolingDetToFreq(-1*p.consts.Gamma,8),coolingDetToFreq(1*p.consts.Gamma,8),p.StepNum);
CoolingResonanseFreqs=linspace(-1,1,numSteps)*p.consts.Gamma;
p.loopVals={CoolingResonanseFreqs};
p.(p.loopVars{1})=p.INNERLOOPVAR;
%%

p.s=sqncr();
p.s.addBlock({'setICEDetuning','Laser Name','cooling','detuning',p.resonantImagingDetuning,'evtNum',2});
% p.s.addBlock({'pause','duration',p.resonantImagingDetuning})
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'Release MOT'});
% p.s.addBlock({'GenPause','channel','none','value','none','duration',1e6});
p.s.run();


% averagedparams=mean(squeeze(r.fitParams{1}),3);
% figure;plot(CoolingResonanseFreqs./p.consts.Gamma,squeeze(averagedparams(2,:,:,:)),'o-');
