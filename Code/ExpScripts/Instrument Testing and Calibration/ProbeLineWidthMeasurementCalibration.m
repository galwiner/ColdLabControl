clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
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
scp = keysightScope('10.10.10.127',[],'ip');
scp.setState('stop');
pause(1)
p.expName = 'ProbeLineWidthMeasurementCalibration';
p.rampTime =1e6;
p.rampCenter = 450*4-20;
inst.DDS.setupSweepMode(2,p.rampCenter,40,p.rampTime,8);
p.s = sqncr;
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',p.rampTime,'value','high'});
p.s.addBlock({'pause','duration',2*p.rampTime})
p.s.run;
pause(1)
data = scp.getChannels([1,2,3,4]);
%%
% smoothData

load('D:\Box Sync\Lab\ExpCold\Measurements\2019\07\09\090719_226.mat');
raw_dat=r.scopeRes{1};
data=r.scopeRes{1};
smoothFactor = 100;
for ii = 1:5
    data(:,ii) = smooth(data(:,ii),smoothFactor);
    
end

EOM_df=24785e3; %Hz
idx_t0=7906;
idx_t25Mhz=38930;
dt=data(idx_t25Mhz,1)-data(idx_t0,1);
dfdt=EOM_df/dt; %freq to time conversion factor

figure;
plot(data(:,4)./max(data(:,4)));
hold on
plot(data(:,3)./max(data(:,3)));
plot(data(:,5)./max(data(:,5)));
plot(idx_t0,data(idx_t0,5)/max(data(:,5)),'ok');
plot(idx_t25Mhz,data(idx_t25Mhz,5)/max(data(:,5)),'ok');

idx_zero_cross=7935;

t=data(idx_zero_cross-50:idx_zero_cross+50,1);
y=data(idx_zero_cross-50:idx_zero_cross+50,4);
figure;
plot(data(:,1),data(:,4));
hold on
plot(t,y./max(data(:,4)),'ok');
xlabel('time [S]');
ylabel('PDH signal [V]');
[f,gof1]=fit(t,y,'poly1');
dVdf=f.p1/dfdt; %voltage per Hz slope

t0=data(555,1); %ramp start time
freqs=(p.rampCenter-20)+(data(:,1)-t0).*dfdt*1e-6; %freq x scale
figure; 
plot(freqs,data(:,4))
hold on
plot(freqs(idx_zero_cross),data(idx_zero_cross,4),'ok')

DDS_freq=freqs(idx_zero_cross)/8;
spectrumAnalyser_cent=freqs(idx_zero_cross)/4;



    