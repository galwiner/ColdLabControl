%fast mode spectroscopy for mangetic field calibration
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
p.expName = 'fast mode spectroscopy - magnetic field calibration';

% inst.scopes={keysightScope('10.10.10.118','MOTSCOPE','ip')};


%% 
% inst.scopes{1}.setState('single')

p.NAverage=1;

% numSteps=10;

% p.loopVars = {'HHXCurrent'};
% p.loopVals={linspace(-0.01,-1,numSteps)};
% p.(p.loopVars{1})=p.INNERLOOPVAR;


% p.compressionEndCurrent=100;
% p.compressionTime=20e3;
p.scanTime=300;
p.scanSpan = 100;
inst.DDS.setupSweepMode(2,5611,p.scanSpan,p.scanTime,32)
psu=inst.BiasCoils{1};
p.zeemanBiasTime=p.scanTime*40;
psu.configTriggedPulse(p.HHYCurrent,-1,p.zeemanBiasTime);

p.compressionTime = 20e3; %in us
p.compressionEndCurrent=220;
%%
p.s=sqncr();
% p.s.addBlock({'Load MOT'});
% p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',p.compressionEndCurrent});
% p.s.addBlock({'pause','duration',p.compressionTime});
% p.s.addBlock({'pause','duration',20e3});
% p.s.addBlock({'Release MOT'});
% % p.s.addBlock({'pause','duration',1e3});
p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',p.zeemanBiasTime+100,'value','High'});
% p.s.addBlock({'pause','duration',100});
p.s.addBlock({'TrigScope'});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0,'description','probe on'});
% p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','value','high','duration',p.scanTime,'description','DDS scan on'});
% p.s.addBlock({'GenPause','channel','none','value','none','duration',5e5});
p.looping = int16(1);
p.s.run();

% res=mean(r.scopeRes{1},5);
% time=squeeze(res(:,1,:));
% T=squeeze(res(:,5,:));
% figure;
% for ind=1:size(time,2)
% plot(time(:,ind),T(:,ind));
% hold on;
% end
% 
% figure;plot(exp(-T))


%figure
% plot(r.scopeRes{1})


