clear all;
global p;
global r;
global inst;
initp
p.idsLiveMode = 0;
p.pfLiveMode = 1;
p.flashTime = 10;
p.picsPerStep = 1;
p.cameraParams{1}.E2ExposureTime = 1e3;
p.cameraParams{2}.E2ExposureTime = 1e3;

p.expName = 'idsTriggerDelay';
initinst
initr
%%
p.imagingPower = 400;
p.loopVals{1} = linspace(1,20,10);
p.loopVars{1} = 'imageDelay';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.AbsImgTime = 1;
p.s = sqncr;
p.s.addBlock({'setDigitalChannel','channel','imagingTTL','duration',0,'value','low'});
p.s.addBlock({'setImagingPower','channel','ImagingVVAN','duration',0,'value',p.imagingPower,'description','set imaging power'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTopTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'pause','duration',p.imageDelay});
p.s.addBlock({'setDigitalChannel','channel','imagingTTL','duration',p.AbsImgTime,'value','High'});
p.s.addBlock({'GenPause','duration',1e5});
p.s.run;
imageViewer(r.images{2})