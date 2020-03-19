%This experiment tests the bias boils 

clear all
imaqreset
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.picsPerStep=2;
p.pfPlaneLiveMode=1;
p.pfTopLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.expName = 'Preassure measurment via loading time';
p.MOTLoadTime = 10e6;
initinst
initr
inst.scopes{1}.setTimeout(0.2);
inst.scopes{1}.setTimebase(10);
inst.scopes{1}.setTimeOffset(4);
%% setup seq
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',50e4});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.looping = int16(1);
p.s.run();

%%

t=r.scopeRes{1}(:,1);
v=r.scopeRes{1}(:,3);
figure
plot(t,v,'o');

