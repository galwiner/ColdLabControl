clear all;
instrreset;
global p;
global r;
global inst;
initp;
p.hasTTresults = 1;
p.ttDumpMeasurement = 1;
p.expName = 'sanity slow mode spectroscopy';
initinst;
initr;
p.probePower = 3e-9;
loadNoise;
%%
p.s = sqncr;
p.s.addBlock({p.asyncActions.setZeemanPumpPower,'value',p.zeemanPumpPower,'ND',p.ZeemanNDList});
p.s.addBlock({p.asyncActions.setZeemanRepumpPower,'value',p.zeemanRepumpPower,'ND',p.zeemanRepumpND});
p.s.addBlock({'setProbePower','value',p.probePower,'duration',0});
p.s.addBlock({'Load MOT'});
p.s.runStep;
p.gateNum = 5e3;
p.gateTime = 20;
p.NInner = 20;
p.probeOffset = -4;
p.probeSpan = 80;
p.NAverage=5;
p.loopVals{1} = fliplr(linspace(p.probeOffset-p.probeSpan/2,p.probeOffset+p.probeSpan/2,p.NInner));
p.loopVars{1} = 'probeDet';
p.probeDet = p.INNERLOOPVAR;
p.MagneticPulseTime=(p.gateNum) * (p.gateTime+1) + 5e3+30e3;
p.s = sqncr;
p.s.addBlock({'setProbeDetuning','detuning',p.probeDet,'from',2,'to',3,'multiplier',8});
p.s.addBlock({'LoadDipoleTrapAndPump'});
p.s.addBlock({'setDigitalChannel','channel','SPCMShutter','value','high','duration',0});
p.s.addBlock({'pause','duration',5e3}); %shutter open delay
p.s.addBlock({'forStart'});
% p.s.addBlock({'measureSPCMOnlyProbe'});
p.s.addBlock({p.compoundActions.measureSPCMWith480Control});
p.s.addBlock({'forEnd','value',p.gateNum});
p.s.addBlock({'resetSystem'});
p.s.run;
% keepDipoleTrapWarm
[chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,matFileName]=ttDumpProcessing(r.fileNames);
load(matFileName)
p.runAutoPlot = 1;
if p.runAutoPlot==0
    return
end
%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
%%
r.supGateN = 10;
r.supGate = ceil(p.gateNum/r.supGateN);
r.sectionsList = {1:r.supGate:(p.gateNum+1)};
r.sectionByList = string('gate');
r.sectionedRes = sectionTTResV2(r.ttRes.chN_phot_cycles,r.ttRes.chN_phot_gc,r.ttRes.chN_phot_time,r.sectionsList,r.sectionByList,p.NAverage);
r.supGateCents = getSuperGateCenterFromSectionList(r.sectionsList);
r.trans = (r.sectionedRes.phot_per_cycle/(r.supGate*p.gateTime/2)-p.noiseRate)/(p.bgRate-p.noiseRate);
ip = [60,3.03,1,0,-4];
lp = [0,3.03,1,0,-inf];
up = [inf,3.03,1,0,inf];
r.fitRes = {};
r.r2 = [];
r.coefs = zeros(5,r.supGateN);
for ii = 1:r.supGateN
[r.fitRes{end+1},r.gof] = fitExpLorentzian(p.loopVals{1},r.trans(:,ii),ip,lp,up);
r.coefs(:,ii) = coeffvalues(r.fitRes{end});
r.r2(ii) = r.gof.rsquare;
end
r.ODs = r.coefs(1,:);
r.fitDets = linspace(min(p.loopVals{1}),max(p.loopVals{1}),1e3);
figure;
plot(r.supGateCents,r.ODs)
figure;
tiledlayout('flow');
for ii = 1:r.supGateN
    nexttile
plot(p.loopVals{1},r.trans(:,ii),'o')
hold on
plot(r.fitDets,r.fitRes{ii}(r.fitDets));
legend('data','fit','Location','southwest')
xlabel('detuning [MHz]')
ylabel('Transmission')
title(sprintf('Gate # %f. OD = %0.2f',r.supGateCents(ii),r.ODs(ii)))
set(gca,'fontsize',12)
end
%%

