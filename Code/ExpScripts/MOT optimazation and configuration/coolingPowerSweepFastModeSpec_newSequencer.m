%cooling power sweep with fast mode spectroscopy
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
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr
inst.DDS.setupSweepMode(2,5728,500,500,32)
% inst.DDS.setupSweepMode(2,5728,500,500,32)
% inst.DDS.setFreq(2,6000/32,0,0)
p.expName = 'cooling power sweep fast mode spectroscopy - cold cloud, no magnetic field shutdown';

% inst.scopes={keysightScope('10.10.10.118','MOTSCOPE','ip')};
%%setting up the sweep
p.loopVars = {'coolingPower'};
coolingPowerVals=linspace(880,880,1);
p.loopVals={coolingPowerVals};

p.(p.loopVars{1})=p.INNERLOOPVAR;

%% 
% inst.scopes{1}.setState('single')
%load the MOT
% p.s=sqncr();
% p.s.addBlock({'Load MOT'});
% p.looping = int16(1);
% p.s.run();

%%clear the sequencr

duration_repump_only=100;
duration_in_the_dark=20;
scan_t=500;
total_t_MOT_off=scan_t*2+duration_in_the_dark;

p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','low','duration',total_t_MOT_off,'description','cooling beams off','inverted','true'});
p.s.addBlock({'pause','duration',duration_repump_only});
% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','value','low','duration',150,'description','repump beams off','inverted','true'});
%p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','value','low','duration',total_t_MOT_off-duration_repump_only,'description','repump beams off','inverted','true'});
% p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','value','low','duration',total_t,'description','AHH circ IGBT off','inverted','true'});
% p.s.addBlock({'setAnalogChannel','channel','CircCoil','duration',total_t,'value',p.circCurrent,'description','AHH circ CURRENT off','inverted','true'});
p.s.addBlock({'pause','duration',duration_in_the_dark});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',scan_t*2,'description','probe on'});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',500,'description','Control beam on'});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','value','high','duration',scan_t,'description','DDS scan on'});
% p.s.addBlock({'GenPause','channel','none','value',0,'duration',0.5e6});

p.looping = int16(1);
p.s.run();

figure
plot(r.scopeRes{1}(:,1),r.scopeRes{1}(:,2:end))





















