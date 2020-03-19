%Thermometry cooling power vs. cooling detuning

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
p.hasPicturesResults=1;
p.picsPerStep=4;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.calcTemp=1;
p.DEBUG=DEBUG;
p.expName = 'thermometry_cooling_power_colling_detuning';
p.TOFtimes=[300,1000,5000,10000];
p.cameraParams{1}.E2ExposureTime=200;
initinst
initr
%% setup seq

p.loopVars = {'coolingPower','coolingDetuning'};
coolingPowerVals=linspace(880,880,1);
coolingDetuningVals=linspace(-10,-2,15)*p.consts.Gamma;
p.loopVals={coolingPowerVals,coolingDetuningVals};

p.(p.loopVars{1})=p.INNERLOOPVAR;
p.(p.loopVars{2})=p.OUTERLOOPVAR;
% p.loopVars = {'coolingPower'};
% p.(p.loopVars{1})=p.INNERLOOPVAR;
% p.loopVals={linspace(400,880,5)};

p.s=sqncr();
p.s.addBlock({'setICEDetuning','Laser Name','cooling','Detuning',p.OUTERLOOPVAR});
p.s.addBlock({'ToF'});
p.s.addBlock({'TrigScope'});
p.s.run();

%% Temp result display
figure;
yyaxis left
plot(p.loopVals{2}/p.consts.Gamma,r.Tx{1},'-ob')
% set(gca,'LineColor','b')
xlabel('Detuning [\Gamma]');
ylabel('T [\muK]');
hold on
plot(p.loopVals{2}/p.consts.Gamma,r.Ty{1},'-ok')
% set(gca,'LineColor','k')
yyaxis right
plot(p.loopVals{2}/p.consts.Gamma,r.atomNum{1}(1,:),'-or')
% set(gca,'LineColor','r')
ylabel('Atom num');
%% Density result display


