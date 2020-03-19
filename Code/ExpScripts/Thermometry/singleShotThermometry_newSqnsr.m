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
p.coolingDet = -3*p.consts.Gamma;
p.picsPerStep=2;
p.calcTemp=1;
p.NTOF = 2;
p.TOFtimes = [0,5e3];
initinst
initr
p.expName='Single Shot Thermometry';
p.SingleTOFTime = 5e3;
%%
p.s.getbgImg();
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger photo'});%Trigger camera
p.s.addBlock({'pause','duration',40e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',p.SingleTOFTime})
p.s.addBlock({'TakePic'});
p.s.run;
%%
% imageViewer(r.images{1})
