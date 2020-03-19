%fast mode spectroscopy on a cold cloud, in live camera mode

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
p.scanTime=300;
p.scanSpan = 100;
inst.DDS.setupSweepMode(2,5611,p.scanSpan,p.scanTime,32)
p.expName = 'fast mode spectroscopy - cold cloud, no magnetic field shutdown';

% inst.scopes={keysightScope('10.10.10.118','MOTSCOPE','ip')};


%% 
% inst.scopes{1}.setState('single')
%load the MOT
p.circCurrent=40;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.looping = int16(1);
p.s.run();

%%clear the sequencr
p.NAverage=5;
delay_t=100;
numSteps=10;

p.loopVars = {'compressionEndCurrent'};
compressionEndVals=linspace(40,220,numSteps);
p.loopVals={compressionEndVals};
p.(p.loopVars{1})=p.INNERLOOPVAR;

total_t=scan_t*2+delay_t;
% p.compressionEndCurrent=100;
p.compressionTime=20e3;

p.s=sqncr();

p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',p.compressionEndCurrent});
p.s.addBlock({'pause','duration',200e3});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','low','duration',total_t,'description','cooling beams off','inverted','true'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','value','low','duration',total_t,'description','repump beams off','inverted','true'});
% p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','value','low','duration',total_t,'description','AHH circ IGBT off','inverted','true'});
% p.s.addBlock({'setAnalogChannel','channel','CircCoil','duration',total_t,'value',p.circCurrent,'description','AHH circ CURRENT off','inverted','true'});
p.s.addBlock({'pause','duration',delay_t});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',scan_t*2*0,'description','probe on'});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',500,'description','Control beam on'});
p.s.addBlock({'setDigitalChannel','channel','DDS2_CTL','value','high','duration',scan_t,'description','DDS scan on'});
p.s.addBlock({'pause','duration',0.5e6});
p.s.addBlock({'setCircCurrent','channel','CircCoil','value',40,'duration',0});
p.s.addBlock({'GenPause','channel','none','value',0,'duration',0.5e6});
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


