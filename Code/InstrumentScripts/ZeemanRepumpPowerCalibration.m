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
p.expName='zeeman repump power calibraion';
%power measured before fiber input 

p.hasScopResults=0;
%%
V=linspace(0.5,7,25);
fprintf('background');
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ZEEMANSwitch,'value','low','duration',0});
p.s.run();
pause(0.2);
noise=mean(MeasPowerMeter);
pause(2)
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ZEEMANSwitch,'value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ZeemanShutter,'value','high','duration',0});
p.s.run();
pause(2);
for ind=1:length(V)
fprintf('voltage: %f\n',V(ind));
voltage=V(ind);
inst.KeithleyPSU.setVoltage(1,voltage)
pause(2)
pwr(ind)=mean(MeasPowerMeter)-noise;
disp(sprintf('Loop # %d out of %d',ind,length(V)));
pause(2)
end
%%
figure;
plot(V,pwr)
% goodInds = 4:21;
% V = V(goodInds);
% pwr = pwr(goodInds);
% save('ZeemanRepumpPower2AO.mat','V','pwr')
