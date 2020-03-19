%cooling power and cooling detuning sweep with fast mode spectroscopy
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
p.expName = 'cooling power and det sweep fast mode spectroscopy - cold cloud, no magnetic field shutdown';

% inst.scopes={keysightScope('10.10.10.118','MOTSCOPE','ip')};
%%setting up the sweep
p.loopVars = {'coolingPower','coolingDetuning'};
coolingPowerVals=linspace(100,880,10);
coolingDetuningVals=linspace(-9,-1,10)*p.consts.Gamma;
p.loopVals={coolingPowerVals,coolingDetuningVals};

p.(p.loopVars{1})=p.INNERLOOPVAR;
p.(p.loopVars{2})=p.OUTERLOOPVAR;

%% 
% inst.scopes{1}.setState('single')
%load the MOT
% p.s=sqncr();
% p.s.addBlock({'Load MOT'});
% p.looping = int16(1);
% p.s.run();

%%clear the sequencr

delay_t=2800;
scan_t=500;
total_t=scan_t*2+delay_t;

p.s=sqncr();
p.s.addBlock({'setICEDetuning','Laser Name','cooling','coolingDetuning',p.OUTERLOOPVAR});
p.s.addBlock({'pause','duration',500});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','low','duration',total_t,'description','cooling beams off','inverted','true'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','value','low','duration',total_t,'description','repump beams off','inverted','true'});
% p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','value','low','duration',total_t,'description','AHH circ IGBT off','inverted','true'});
% p.s.addBlock({'setAnalogChannel','channel','CircCoil','duration',total_t,'value',p.circCurrent,'description','AHH circ CURRENT off','inverted','true'});
p.s.addBlock({'pause','duration',delay_t});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',scan_t*2,'description','probe on'});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',500,'description','Control beam on'});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','value','high','duration',scan_t,'description','DDS scan on'});
p.s.addBlock({'GenPause','channel','none','value',0,'duration',0.5e6});

p.looping = int16(1);
p.s.run();




