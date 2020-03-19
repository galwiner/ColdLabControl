clear all
global p

global r
global inst
DEBUG=0;
initp
p.expName='Compression Dinamics';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=1;
p.calcTemp = 0;
p.cameraParams{1}.E2ExposureTime=40;
p.DEBUG=DEBUG;
%
initinst
initr
p.MOTLoadTime = 3e6;

%%
nsteps = 1;
% currVals = linspace(10,120,nsteps);
detuningVals = linspace(0,0,nsteps)*p.consts.Gamma;
% p.loopVals = {currVals,detuningVals};
p.loopVals{1} = detuningVals;
p.loopVars{1} = 'repumpDet';
% p.loopVars = {'circCurrent','coolingDet'};
p.(p.loopVars{1}) = p.INNERLOOPVAR;
% p.(p.loopVars{2}) = p.OUTERLOOPVAR;
p.s = sqncr;
p.s.addBlock({'setRepumpDetuning','duration',0,'value',p.repumpDet});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'GenPause','duration',1e3});
p.s.run;
% imageViewer(r.images{1}(:,:,:))
%
figure;
% imagesc(p.loopVals{1},p.loopVals{2}/p.consts.Gamma,squeeze(r.atomNum{1}))
plot(p.loopVals{1}/p.consts.Gamma,squeeze(r.atomNum{1}))







