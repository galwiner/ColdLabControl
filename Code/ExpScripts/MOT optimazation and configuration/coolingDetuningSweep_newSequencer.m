%find optimal cooling detuning

clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=1;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.cameraParams{1}.E2ExposureTime=20;
p.DEBUG=DEBUG;
initinst
initr
% inst.DDS.setFreq(2,p.probeLockCenter/32,0,0);
% p.circCurrent=40;
%%setting up the sweep
p.expName='Cooling detunign sweep';
p.loopVars = {'coolingDet'};
numSteps=15;
coolingDetVals=linspace(-6,-2,numSteps)*p.consts.Gamma;

p.loopVals={coolingDetVals};
% 
p.(p.loopVars{1})=p.INNERLOOPVAR;
% p.(p.loopVars{2})=p.OUTERLOOPVAR;

%% test compression

p.cameraParams{1}.E2ExposureTime=20;
inst.scopes{1}.sc.Timeout=60;
p.s=sqncr();
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0,'description','probe on'});
p.s.addBlock({'setICEFreq','Laser Name','cooling','freq',p.coolingDet,'evtNum',1});
p.s.addBlock({'pause','duration',100e3});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',300e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'GenPause','channel','none','value','none','duration',p.MOTLoadTime});
p.looping = int16(1);
p.s.run();

AtomNum=squeeze(r.fitParams{1}(7,1,:,:)); %integrated intensity in the gaussian
AtomNum= AtomNum*atomNumberFromCollectionParams();
peakDensity=AtomNum./squeeze(r.fitParams{1}(6,1,:,:))./squeeze(r.fitParams{1}(5,1,:,:).^2)/((2*pi)^(3/2)); %in 1/m^3
peakDensity = peakDensity*1e-6;
%%
figure;
subplot(3,1,1)
plot(coolingDetVals,peakDensity,'o-');
title('density')
xlabel('cooling det [MHz]')
ylabel('density [cc^-1]')
subplot(3,1,2)
plot(coolingDetVals,squeeze(r.fitParams{1}(6,1,:,:)),'or-')
hold on
plot(coolingDetVals,squeeze(r.fitParams{1}(5,1,:,:)),'ob-')
title('gaussian width')
xlabel('cooling det [MHz]')
legend('\sigma_x','\sigma_z')
subplot(3,1,3)
plot(coolingDetVals,AtomNum,'or-')
title('atom number')
xlabel('cooling det [MHz]')


figure; 
scopeTraces=squeeze(r.scopeRes{1});
t=scopeTraces(:,1,1);
V=squeeze(scopeTraces(:,3,:));
plot(t,V);
