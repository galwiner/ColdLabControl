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
p.expName='776 control power calibration';
%power measured after DPAOM 

p.hasScopResults=0;
%%
V=linspace(0.3,3,40);
for ind=1:length(V)
disp(sprintf('Loop # %d out of %d',ind,length(V)));
fprintf('voltage: %f\n',V(ind));
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel','CTRL776TTL','value','high','duration',0});
p.s.addBlock({'setAnalogChannel','channel','ImagingVVAN','value',V(ind),'duration',0});
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


