clear all
global p
global r
global inst
initp
p.hasScopResults=0;
p.hasPicturesResults=0;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=0;
initinst
initr
p.expName='776 control power calibration Varification';
%power measured after DPAOM 

p.hasScopResults=0;
%%
setPower = linspace(0.02,11,20);
for ind=1:length(setPower)
disp(sprintf('Loop # %d out of %d',ind,length(setPower)));
fprintf(':power: %f\n',setPower(ind));
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','value','high','duration',0});
p.s.addBlock({'set776ControlPower','duration',0,'value',setPower(ind),'channel','ImagingVVAN'});
p.s.addBlock({'GenPause','channel','none','value',0,'duration',5e5});
p.s.runStep;
pwr(ind)=mean(MeasPowerMeter);
jj = 1;
while isnan(pwr(ind)) && jj<6
    warning('No power measured, runing again')
    pwr(ind)=mean(MeasPowerMeter);
    jj = jj + 1;
end
pause(4)
end

figure;
plot(setPower,pwr*1e3)
