%probe at resonance, transmission measured for different probe powers

clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr


p.probeLockCenter = 5611+50;

% inst.DDS.setupSweepMode(2,p.probeLockCenter,200,500,32);

p.expName = 'probe at resonance, transmission measured for different probe power levels';

%first load a MOT
p.hasScopResults=0;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.looping = int16(1);
p.s.run();

%%then set up the sweep
p.loopVars = {'probePower'};
probePowerVals=ProbePower2AO(linspace(10e-6,230e-6,15));
p.loopVals={probePowerVals};

p.(p.loopVars{1})=p.INNERLOOPVAR;
p.f_sweep_t=500;
p.duration_repump_only=100;
p.duration_in_the_dark=20;
p.total_t_MOT_off=p.duration_repump_only+p.f_sweep_t;
p.f_sweep_span=200;
inst.DDS.setupSweepMode(2,p.probeLockCenter,p.f_sweep_span,p.f_sweep_t,32);
%% 
% inst.scopes{1}.setState('single')
%load the MOT


%%clear the sequencr

p.hasScopResults=1;
p.s=sqncr();
p.s.addBlock({'setAnalogChannel','channel','PRBVVAN','value',p.INNERLOOPVAR,'duration',0,'description','set probe power'});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','low','duration',0,'description','cooling beams off'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','value','low','duration',0,'description','cooling beams off'});

% p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','value','low','duration',0,'description','repump beams off'});
p.s.addBlock({'pause','duration',100});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','value','high','duration',p.f_sweep_t,'description','DDS scan on'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',p.f_sweep_t*2,'description','probe on'});
p.s.addBlock({'GenPause','channel','none','value',0,'duration',p.f_sweep_t*2});

p.looping = int16(1);
p.s.run();

%%
% 
dat=r.scopeRes{1};
probePowerVals=p.loopVals{1};
figure
for ind=1:length(probePowerVals)
t=dat(:,1,1,ind);
v=dat(:,5,1,ind);
plot(t,v,'DisplayName',sprintf('%.2f nW',1e6*AO2ProbePower(probePowerVals(ind))));
hold on
end
legend 
title('Probe Transmission for different probe power levels');
ylabel('Probe Transmission [AU]')
xlabel('t [s]')

