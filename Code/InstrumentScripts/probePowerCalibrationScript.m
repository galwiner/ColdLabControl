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
p.hasPicturesResults=0;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr

%power measured after DPAOM 

p.hasScopResults=0;

% V=[0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,1,1.2,1.5,1.6,1.8,2,2.3,2.4,2.5,2.8,3,3.4,3.5,3.6]; %V
V=linspace(0,3.6,50); %DO NOT EXCEED 3.6 VOLTS!!
for ind=1:length(V)
fprintf('voltage: %f\n',V(ind));
voltage=V(ind);
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0,'description','probe on'});
p.s.addBlock({'setAnalogChannel','channel','PRBVVAN','value',V(ind),'duration',0});
p.s.addBlock({'GenPause','channel','none','value',0,'duration',2e6});
p.s.run();
pwr(ind)=mean(MeasPowerMeter);
pause(2)
end

figure;plot(V,pwr,'ok')
hold on
V1=linspace(0,3.6,100);
plot(V1,interp1(V,pwr,V1),'o-r')

