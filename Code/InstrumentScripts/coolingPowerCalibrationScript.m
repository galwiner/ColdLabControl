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
% V=[0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,1,1.2,1.5,1.6,1.8,2,2.3,2.4,2.5,2.8,3,3.4,3.5,3.6]; %V
V=CoolingPower2AO(linspace(100,880,40)); %DO NOT EXCEED 3.6 VOLTS!!
for ind=1:length(V)
fprintf('voltage: %f\n',V(ind));
voltage=V(ind);
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','high','duration',0});
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','value',V(ind),'duration',0});
p.s.addBlock({'GenPause','channel','none','value',0,'duration',2e6});
p.s.run();
% pwr(ind)=mean(MeasPowerMeter);
[ana,~]=readFPGAOutputChannels();
pwr(:,ind)=ana(1:3);
disp(sprintf('Loop # %d out of %d',ind,length(V)));
pause(2)
end

figure;
plot(V,pwr(1,:),'*k')

hold on
plot(V,pwr(2,:),'*r')
plot(V,pwr(3,:),'*g')

f1=fit(V',pwr(1,:)','poly1');
f2=fit(V',pwr(2,:)','poly1');
f3=fit(V',pwr(3,:)','poly1');
plot(V,f1(V),'-k');
plot(V,f2(V),'-r');
plot(V,f3(V),'-g');
%%


%%verify the calibration
numSteps=1;
setPwr=linspace(0,900,numSteps);
for ind=1:numSteps
p.s=sqncr();
% p.s.addBlock({'setAnalogChannel','channel','pixelfly','coolingPower',setPwr(ind),'duration',0});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','value','high','duration','0'});
p.s.addBlock({'GenPause','channel','none','value',0,'duration',5e5});
p.s.run();
measPwr(ind)=mean(MeasPowerMeter);
end
figure;
plot(setPwr,measPwr,'o');


% save('coolingCalData_25062018.mat','pwr','V')
