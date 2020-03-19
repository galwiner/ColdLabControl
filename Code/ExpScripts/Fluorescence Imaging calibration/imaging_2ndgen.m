clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=0;
p.picsPerStep=1;
p.calcTemp=0;
p.DEBUG=DEBUG;
p.cameraParams{2}.ROI=[950 418 200 300]
initinst
initr
p.looping=1;
p.expName = 'Top MOT picture (2nd gen imaging)';
p.DTParams.TrapTime=30000;
p.flashTime=50
fig=figure

%%

for ind=1:1
p.s=sqncr(); 
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','low','duration',0})
p.s.addBlock({'pause','duration',2e3});
p.s.addBlock({'TakePic'});
p.s.run();
imagesc(gca,r.images{2})

colorbar

end

%%


