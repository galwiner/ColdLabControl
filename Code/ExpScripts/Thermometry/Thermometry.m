clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
p.hasPicturesResults=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.DEBUG=DEBUG;
% p.coolingDet = -3*p.consts.Gamma;
p.picsPerStep=p.NTOF;
p.calcTemp=1;
initinst
initr
p.expName='Thermometry';



%%
p.s.getbgImg();
p.s=sqncr();
p.s.addBlock({'ToF'});
p.s.run;
%%
% imageViewer(r.images{1})
