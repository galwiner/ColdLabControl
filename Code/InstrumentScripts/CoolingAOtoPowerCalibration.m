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
p.expName='cooling beams power calibration';
%power measured after DPAOM 

p.hasScopResults=0;
%%
V=linspace(0.1,2,40); %DO NOT EXCEED 3.6 VOLTS!!
for ind=1:length(V)
fprintf('voltage: %f\n',V(ind));
voltage=V(ind);
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','high','duration',0});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','value',V(ind),'duration',0});
p.s.addBlock({'GenPause','channel','none','value',0,'duration',2e6});
p.s.run();
pwr(ind)=mean(MeasPowerMeter);
disp(sprintf('Loop # %d out of %d',ind,length(V)));
pause(2)
end

