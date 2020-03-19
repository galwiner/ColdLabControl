clear all
global p
global r
global inst
initp
p.kdc = 1;
p.hasScopResults=0;
p.hasPicturesResults=0;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=0;
initinst
initr
p.expName='control 480 Power calibration';
%power measured after DPAOM 

p.hasScopResults=0;
%%
power = linspace(0.004,0.7,40);
% power = linspace(1.1,295,40);
NDList = [15,16];
for ind=1:length(power)
disp(sprintf('Loop # %d out of %d',ind,length(power)));
fprintf('power: %f\n',power(ind));
p.s=sqncr();
p.s.addBlock({p.asyncActions.setControlPower,'power',power(ind),'ND',NDList})
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'GenPause','channel','none','value',0,'duration',1e6});
p.s.runStep;
pwr(ind)=mean(MeasPowerMeter);
jj = 1;
while isnan(pwr(ind)) && jj<6
    warning('No power measured, runing again')
    pwr(ind)=mean(MeasPowerMeter);
    jj = jj + 1;
end
pause(2)
end
figure;
plot(power,pwr*1e3)
% save('controlPowerCAlibrationVarification_WithND','power','pwr')
%%
% 
% for ii = 1:length(power)
%     
%    alpha(ii) = controlPower2angle(power(ii));
% end