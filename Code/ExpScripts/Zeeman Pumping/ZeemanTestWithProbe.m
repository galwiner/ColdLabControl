%This experiment tests magnetic field by measuring the zeeman splliting of
%the probe

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
p.picsPerStep=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.expName = 'ZeemanTestWithProbe';
% p.HHYCurrent = -0.052; %in A. Good valeu -0.052
% p.HHZCurrent = 0.095; %in A
% p.HHXCurrent = -0.03; %in A 
% p.cameraParams{1}.E2ExposureTime = 300;
initinst
initr
%% setup seq

p.SweepTime = 400; %in us
% inst.DDS.setupSweepMode(2,5611,300,p.SweepTime,32)
p.ProbeSwipRep = 31;
p.s=sqncr();
p.s.addBlock({'setAnalogChannel','channel','PRBVVAN','value',ProbePower2AO(200e-6),'duration',0});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',p.SweepTime,'value','high'});
for ii = 1:(p.ProbeSwipRep-1)/2
p.s.addBlock({'pause','duration',2*p.SweepTime});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','duration',p.SweepTime,'value','high'});
end
p.s.addBlock({'pause','duration',2*p.SweepTime});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.looping = int16(8);
%%
p.s.run();

