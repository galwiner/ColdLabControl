clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults = 0;
p.hasTTresults = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
p.looping=1;
%%
p.expName = 'ProbeLineWidthMeasurementCalibrationWithPolarizationLocking';
inst.scopes{1}.setState('single')
pause(0.3)
r.scopeRes{1} = inst.scopes{1}.getChannels([1,2,3]);
r.scopeDigRes{1} = inst.scopes{1}.getDigitalChannels;
customsave;
%%
load('100719_02.mat')
polLock = r.scopeRes{1}(:,2);
sas = r.scopeRes{1}(:,3)+r.scopeRes{1}(:,4);
time =  r.scopeRes{1}(:,1);
idx = 1:length(sas);
sas0 =1.4e4+601;
sas1 = 1.4e4+2151;
df = 133.5; %133 MHz is the diff between the sas lines (F=2->F'=3 and the F=2->F'=2\3 croseover
dt = time(sas1)-time(sas0);
dfdt = df/dt;
pol0 = 1.4e4+598;
fity = polLock(pol0-50:pol0+50);
fitx = time(pol0-50:pol0+50);
fo = fit(fitx,fity,'poly1');
figure;
yyaxis left
plot(idx,polLock);
hold on
plot(pol0,polLock(pol0),'ok')
yyaxis right
plot(idx,sas);
hold on;
plot(sas0,sas(sas0),'ok')
plot(sas1,sas(sas1),'ok')

figure;
plot(fitx,fity)
hold on
plot(fo)

dvdt = fo.p1;
dvdf = dvdt/dfdt;


