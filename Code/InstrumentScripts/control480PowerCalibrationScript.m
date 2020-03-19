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
Angle=linspace(0,50,30);
for ind=1:length(angle)
disp(sprintf('Loop # %d out of %d',ind,length(angle)));
fprintf('angle: %f\n',angle(ind));
p.s=sqncr();
p.s.addBlock({p.asyncActions.setKDCAngle,'angle',angle(ind)})
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'GenPause','channel','none','value',0,'duration',10e6});
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
plot(angle,pwr)
allpwr = pwr;
allangle = Angle;
%%

% goodInds = 3:28;
% pwr = pwr(goodInds);
% angle = angle(goodInds);
% save('controlAngle2Power','pwr','Angle')
