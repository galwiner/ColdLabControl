clear all;
global p;
global r;
global inst;
initp
p.idsLiveMode = 0;
p.pfLiveMode = 0;
p.flashTime = 500;
p.picsPerStep = 2;
p.cameraParams{1}.E2ExposureTime = 1e3;
p.cameraParams{2}.E2ExposureTime = 1e3;
p.DTParams.TrapTime = 1;
initinst
initr
%%
p.loopVals{1} = [0.06,0.1];
p.loopVars{1} = 'DTParams.repumpLoadingPower';
p.DTParams.repumpLoadingPower = p.INNERLOOPVAR;
p.s = sqncr;
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePic'});
p.s.run;
